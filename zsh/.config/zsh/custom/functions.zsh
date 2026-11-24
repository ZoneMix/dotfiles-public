# age helpers read RECIPIENT (an age public key) and IDENTITY_FILES (an array of
# identity file paths) from ~/.profile.local.

history_format() {
  tail -n $1 ~/.zsh_history |
  perl -MPOSIX=strftime -0777 -ne '
    while (/^: (\d+):\d+;(.*?)(?=\n: \d+:\d+;|\z)/gms) {
      my $date = strftime("%Y-%m-%d %H:%M:%S UTC", gmtime($1));
      my $cmd = $2;
      $cmd =~ s/\\\n/\n/g;
      $cmd =~ s/\n+$//;
      print "# $date\n$cmd\n\n";
    }
  '
}

# IF using linux
history_format_linux() {
  tail -n $1 ~/.zsh_history |
    awk -F ';' '{
    split($1, ts, ":")
    timestamp=ts[2]
    print strftime("%a %b %d %T %Z %Y", timestamp)
    for (i=2; i<=NF; i++) printf "%s;", $i
    printf "\n\n"
  }' | sed 's/;$//g'
}

encrypt_file () {
  output="${1}".$(date +%s).enc
  gpg --encrypt --armor --output ${output} \
    -r $KEYID "${1}" && echo "${1} -> ${output}"
}

decrypt_file () {
  output=$(echo "${1}" | rev | cut -c16- | rev)
  gpg --decrypt --output ${output} "${1}" && \
    echo "${1} -> ${output}"
}

clean_url () {
  cat $1 | sed 's/https:\/\///g' | \
    sed 's/http:\/\///g' | \
    sed 's/\/.*//g' | \
    uniq | \
    sort -t '.' -k1,1n -k2,2n -k3,3n -k4,4n > $2
}


function encrypt_age() {
    local usage="Usage: encrypt_age [-e|--encrypt] [-p|--passphrase] [-a|--armor] <input_file> [output_file]
  -e, --encrypt    : asymmetric encryption (default if no -p)
  -p, --passphrase : symmetric encryption with passphrase
  -a, --armor      : ASCII armor output
  Use '-' as output_file to print to stdout"

    local mode="asymmetric"  # default
    local armor=""
    local input=""
    local output=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -e|--encrypt)
                mode="asymmetric"
                shift
                ;;
            -p|--passphrase)
                mode="symmetric"
                shift
                ;;
            -a|--armor)
                armor="-a"
                shift
                ;;
            -h|--help)
                echo "$usage"
                return 0
                ;;
            *)
                if [[ -z "$input" ]]; then
                    input="$1"
                elif [[ -z "$output" ]]; then
                    output="$1"
                else
                    echo "Error: Too many arguments." >&2
                    echo "$usage" >&2
                    return 1
                fi
                shift
                ;;
        esac
    done

    if [[ -z "$input" ]]; then
        echo "Error: Input file required." >&2
        echo "$usage" >&2
        return 1
    fi

    # Default output filename
    [[ -z "$output" ]] && output="${input}.age"

    case "$mode" in
        symmetric)
            age $armor -p "$input" > "$output"
            ;;
        asymmetric)
            if [[ -z "$RECIPIENT" ]]; then
                echo "Error: RECIPIENT environment variable is not set for asymmetric encryption." >&2
                return 1
            fi
            age $armor -r "$RECIPIENT" "$input" > "$output"
            ;;
    esac

    local exitcode=$?
    if [[ $exitcode -eq 0 ]]; then
        if [[ "$output" == "-" ]]; then
            echo "(output sent to stdout)"
        else
            echo "Encrypted '$input' → '$output'"
        fi
    else
        echo "Encryption failed (age exited with code $exitcode)." >&2
        [[ "$output" != "-" ]] && rm -f "$output" 2>/dev/null
        return $exitcode
    fi
}

function decrypt_age() {
    local usage="Usage: decrypt_age <input_file> [output_file]
  Tries all known identity files, then falls back to passphrase prompt
  Use '-' as output_file to print to stdout"

    local input=""
    local output=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                echo "$usage"
                return 0
                ;;
            *)
                if [[ -z "$input" ]]; then
                    input="$1"
                elif [[ -z "$output" ]]; then
                    output="$1"
                else
                    echo "Error: Too many arguments." >&2
                    echo "$usage" >&2
                    return 1
                fi
                shift
                ;;
        esac
    done

    if [[ -z "$input" ]]; then
        echo "Error: Input file required." >&2
        echo "$usage" >&2
        return 1
    fi

    output="${output:-${input%.age}}"
    [[ "$output" == "$input" ]] && output="${input}.dec"

    local identity_args=()
    if [[ -v IDENTITY_FILES && ${#IDENTITY_FILES[@]} -gt 0 ]]; then
        for file in "${IDENTITY_FILES[@]}"; do
            file="${file/#\~/$HOME}"
            [[ -f "$file" ]] && identity_args+=(-i "$file")
        done
    fi

    local exitcode

    # Try identities first
    if [[ ${#identity_args[@]} -gt 0 ]]; then
        age -d "${identity_args[@]}" "$input" > "$output" 2>/dev/null
        exitcode=$?
        if [[ $exitcode -eq 0 ]]; then
            [[ "$output" == "-" ]] && echo "(decrypted content sent to stdout)" || echo "Decrypted '$input' → '$output'"
            return 0
        fi
    fi

    # Fallback: passphrase
    age -d "$input" > "$output" 2>/dev/null
    exitcode=$?
    if [[ $exitcode -eq 0 ]]; then
        [[ "$output" == "-" ]] && echo "(decrypted content sent to stdout)" || echo "Decrypted '$input' → '$output' (passphrase mode)"
        return 0
    fi

    echo "Decryption failed with all methods (last exit code: $exitcode)." >&2
    [[ "$output" != "-" ]] && rm -f "$output" 2>/dev/null
    return 1
}
