# install.sh と check-freshness.sh が共用する frontmatter パーサ。
# 値の末尾空白・CR (CRLF) は除去し、frontmatter ブロック外の行は見ない。

fm_value() { # $1=file $2=key → frontmatter 内の値 (なければ空)
  awk -v key="$2" '
    NR==1 { if ($0 !~ /^---\r?$/) exit; next }
    /^---[[:space:]]*\r?$/ { exit }
    index($0, key ": ") == 1 {
      v = substr($0, length(key) + 3)
      gsub(/[[:space:]\r]+$/, "", v)
      # YAML で普通に付く引用符を剥がす ("2026-01-01" が生の値として漏れるのを防ぐ)
      if (v ~ /^".*"$/ || v ~ /^'"'"'.*'"'"'$/) v = substr(v, 2, length(v) - 2)
      print v
      exit
    }
  ' "$1"
}

repo_dir_name() { # $1=source URL → clone ディレクトリ名 (.git サフィックスは剥がす)
  basename "$1" .git
}
