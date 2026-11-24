#!/usr/bin/env bash

if ! xcode-select -p &>/dev/null; then
  echo "  Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "  Waiting for Xcode CLT installation to complete..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  echo "  Xcode CLT installed."
else
  echo "  Xcode CLT already installed."
fi

if ! command -v brew &>/dev/null; then
  echo "  Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo "  Homebrew installed."
else
  echo "  Homebrew already installed."
fi

if ! command -v stow &>/dev/null; then
  echo "  Installing GNU Stow..."
  brew install stow
  echo "  Stow installed."
else
  echo "  Stow already installed."
fi
