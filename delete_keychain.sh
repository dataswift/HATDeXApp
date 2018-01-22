#!/bin/bash

security delete-keychain ios-build.keychain
security default-keychain -s login.keychain