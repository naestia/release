#!/usr/bin/env bats

load 'helpers/mock_github.sh'

SCRIPT="$BATS_TEST_DIRNAME/../scripts/verify-version.sh"

setup() {
    setup_github_env
    export TAG_VERSION="1.2.3"

    _WORKDIR="$(mktemp -d)"
    cd "$_WORKDIR"
}

teardown() {
    teardown_github_env
    rm -rf "$_WORKDIR"
}

# ── mix.exs ───────────────────────────────────────────────────────────────────

@test "passes when mix.exs version matches tag" {
    cat > mix.exs << 'EOF'
defmodule MyApp.MixProject do
  def project do
    [app: :my_app, version: "1.2.3"]
  end
end
EOF

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
}

@test "fails when mix.exs version does not match tag" {
    cat > mix.exs << 'EOF'
defmodule MyApp.MixProject do
  def project do
    [app: :my_app, version: "1.0.0"]
  end
end
EOF

    run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [[ "$output" == *"does not match"* ]]
}

@test "fails when mix.exs version is ahead of tag" {
    export TAG_VERSION="1.2.3"
    cat > mix.exs << 'EOF'
defmodule MyApp.MixProject do
  def project do
    [app: :my_app, version: "1.2.4"]
  end
end
EOF

    run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [[ "$output" == *"does not match"* ]]
}

@test "output names the file when mix.exs mismatch" {
    cat > mix.exs << 'EOF'
defmodule MyApp.MixProject do
  def project do
    [app: :my_app, version: "9.9.9"]
  end
end
EOF

    run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [[ "$output" == *"mix.exs"* ]]
}

# ── pyproject.toml ────────────────────────────────────────────────────────────

@test "passes when pyproject.toml version matches tag" {
    cat > pyproject.toml << 'EOF'
[tool.poetry]
name = "my-app"
version = "1.2.3"
EOF

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
}

@test "fails when pyproject.toml version does not match tag" {
    cat > pyproject.toml << 'EOF'
[tool.poetry]
name = "my-app"
version = "9.9.9"
EOF

    run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [[ "$output" == *"does not match"* ]]
}

@test "output names the file when pyproject.toml mismatch" {
    cat > pyproject.toml << 'EOF'
version = "9.9.9"
EOF

    run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [[ "$output" == *"pyproject.toml"* ]]
}

# ── .version ──────────────────────────────────────────────────────────────────

@test "passes when .version matches tag" {
    echo "1.2.3" > .version

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
}

@test "fails when .version does not match tag" {
    echo "0.0.1" > .version

    run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [[ "$output" == *"does not match"* ]]
}

@test "passes when .version has trailing newline" {
    printf "1.2.3\n" > .version

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
}

@test "passes when .version has no trailing newline" {
    printf "1.2.3" > .version

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
}

@test "passes when .version has leading/trailing whitespace" {
    printf "  1.2.3  \n" > .version

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
}

@test "output names the file when .version mismatch" {
    echo "0.0.1" > .version

    run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [[ "$output" == *".version"* ]]
}

# ── Priority ──────────────────────────────────────────────────────────────────

@test "mix.exs takes priority over pyproject.toml" {
    cat > mix.exs << 'EOF'
defmodule MyApp.MixProject do
  def project do
    [app: :my_app, version: "1.2.3"]
  end
end
EOF
    cat > pyproject.toml << 'EOF'
version = "9.9.9"
EOF

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
}

@test "mix.exs takes priority over .version" {
    cat > mix.exs << 'EOF'
defmodule MyApp.MixProject do
  def project do
    [app: :my_app, version: "1.2.3"]
  end
end
EOF
    echo "9.9.9" > .version

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
}

@test "pyproject.toml takes priority over .version" {
    cat > pyproject.toml << 'EOF'
version = "1.2.3"
EOF
    echo "9.9.9" > .version

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
}

@test "all three files present — mix.exs wins and must match" {
    cat > mix.exs << 'EOF'
defmodule MyApp.MixProject do
  def project do
    [app: :my_app, version: "9.9.9"]
  end
end
EOF
    cat > pyproject.toml << 'EOF'
version = "1.2.3"
EOF
    echo "1.2.3" > .version

    run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [[ "$output" == *"mix.exs"* ]]
}

# ── Missing version file ──────────────────────────────────────────────────────

@test "fails when no version file exists" {
    run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [[ "$output" == *"No version file found"* ]]
}

@test "fails with correct error message listing expected files" {
    run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [[ "$output" == *"mix.exs"* ]] || \
    [[ "$output" == *"pyproject.toml"* ]] || \
    [[ "$output" == *".version"* ]]
}

# ── Success output ────────────────────────────────────────────────────────────

@test "prints confirmation message on success" {
    echo "1.2.3" > .version

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [[ "$output" == *"✓"* ]]
}

@test "prints both tag and file version on success" {
    echo "1.2.3" > .version

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [[ "$output" == *"1.2.3"* ]]
}