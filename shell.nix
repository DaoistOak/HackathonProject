{ pkgs ? import <nixpkgs> {} }:

let
  pythonEnv = pkgs.python3Packages.buildEnv {
    name = "my-fastapi-env";
    packages = with pkgs.python3Packages; [
      # Core packages (optional if using requirements.txt)
      python3
      pip
      virtualenv
      # Add any other system-level packages if needed
    ];
  };
in
pkgs.mkShell {
  name = "dev-shell";

  buildInputs = [    # Python and Beware framework
    pythonEnv
    pkgs.python3
    pkgs.python3Packages.pip
    pkgs.python311Packages.virtualenv
    pkgs.postgresql

    # JavaScript and Node.js tooling
    pkgs.nodejs_20
    pkgs.yarn
    pkgs.pnpm
    pkgs.esbuild
    pkgs.typescript

    # General development tools
    pkgs.git
    pkgs.curl
    pkgs.jq
    pkgs.unzip
  ];

  shellHook = ''
    VENV_PATH="${toString ./venv}"

    if [ ! -d "$VENV_PATH" ]; then
      echo "Creating Python virtual environment at $VENV_PATH..."
      python3 -m venv "$VENV_PATH"
      echo "Virtual environment created."
      echo "Activating virtual environment..."
      source "$VENV_PATH/bin/activate"
      echo "Installing required packages from requirements.txt..."
      pip install --upgrade pip
      pip install -r requirements.txt
      echo "Packages installed."
    else
      source "$VENV_PATH/bin/activate"
      echo "Activated existing virtual environment."
    fi

    export DATABASE_URL="postgresql://myuser:password@localhost/mydatabase"
    
    # Make sure PostgreSQL is initialized
    if [ ! -d "$HOME/pgdata" ]; then
      echo "Initializing PostgreSQL database..."
      initdb -D $HOME/pgdata
    fi

    # Start PostgreSQL server if it's not running
    if ! pg_ctl -D $HOME/pgdata status > /dev/null; then
      echo "Starting PostgreSQL..."
      pg_ctl -D $HOME/pgdata -l logfile start
    fi

    echo "PostgreSQL is ready!"
  '';
}
