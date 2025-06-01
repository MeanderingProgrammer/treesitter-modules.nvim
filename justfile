default: update

update:
  # keep documentation in sync with code
  python scripts/update.py
  # https://github.com/kdheepak/panvimdoc
  ../../tools/panvimdoc/panvimdoc.sh \
    --project-name treesitter-modules \
    --input-file README.md

