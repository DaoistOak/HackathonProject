{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "dev-shell";

  buildInputs = [    # Python and Beware framework
    pkgs.python311
    pkgs.python311Packages.pip
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
    source ./venv/bin/activate
    export DATABASE_URL="postgresql://myuser:mypassword@localhost/myapp"
    
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
