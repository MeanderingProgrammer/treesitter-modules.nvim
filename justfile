default: update

update:
  # keep documentation in sync with code
  python scripts/update.py
  # https://github.com/kdheepak/panvimdoc
  ../../../tools/panvimdoc/panvimdoc.sh \
    --input-file README.md \
    --project-name treesitter-modules \
    --description "Original modules from nvim-treesitter master branch"
