#!/bin/bash

cdtoroot() {
  cd "$(git rev-parse --show-toplevel)"
}
