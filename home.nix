{ config, pkgs, ... }:

let
  gpgPkg = config.programs.gpg.package;
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/nix-community/nix-doom-emacs/archive/master.tar.gz;
  }) {
    doomPrivateDir = ./dotfiles/doom;
  };
in {
  nixpkgs = {
    overlays = [
      (import (builtins.fetchTarball {
        url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
      }))
    ];
    config = {
      allowUnfree = true;
    };
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = "rakan";
    homeDirectory = "/home/rakan";
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "22.05";
    sessionVariablesExtra = ''
      export SSH_AUTH_SOCK="$(${gpgPkg}/bin/gpgconf --list-dirs agent-ssh-socket)"
    '';

    packages = with pkgs; [
      # Browser
      firefox
      google-chrome

      # Chat
      element-desktop
      discord
      slack
      tdesktop

      # Desktop
      pcmanfm
      i3lock-fancy
      ledger-live-desktop
      gnome.gnome-calculator
      uhk-agent
      qtpass
      transmission-gtk
      openra
      openraPackages.mods.gen
      hubstaff
      _1password-gui
      obsidian
      okular
      sublime4

      # Fonts
      nerdfonts
      iosevka

      # Dev tools
      doom-emacs
      binutils
      cmake
      gcc
      gnumake
      jemalloc
      libclang
      neovim
      openssl
      pkg-config
      ripgrep
      rustup
      silver-searcher
      sqlite
      wget
      unzip
      zip
      zlib

      # Cli Apps
      awscli
      htop
      neofetch
      pamixer
      noip
      wally-cli

      # Audio / Video
      mpv
      mpd
      vlc

      # Tools
      obs-studio
      pavucontrol
      rofi-pulse-select
      x11idle
    ];

    file = {
      ".config/alacritty.yml".source = dotfiles/alacritty.yml;
      # ".config/awesome".source = (builtins.fetchGit {
      #   url = "git@github.com:rakanalh/awesome-config.git";
      #   ref = "nixos";
      #   fetchSubmodules = true;
      # });
      ".Xresources".source = dotfiles/Xresources;
      ".password-store".source = (builtins.fetchGit {
        url = "ssh://git@github.com/rakanalh/password-store.git";
        ref = "master";
      });
    };
  };
  # environment.pathsToLink = [ "/share/zsh" ];

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };
  };

  programs = {
  # Let Home Manager install and manage itself.
    home-manager.enable = true;
    alacritty.enable = true;
    # emacs = {
    #   enable = true;
    #   package = pkgs.emacsNativeComp;
    #   extraPackages = (epkgs: [ epkgs.vterm ] );
    # };
    # Better 'cat'
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        pager = "less -FR";
      };
    };
    # Really useful for auto-running 'shell.nix', see also: lorri
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    # Better 'ls'
    exa = {
      enable = true;
      enableAliases = true;
    };
    feh = {
      enable = true;
    };
    firefox = {
      enable = true;
      profiles = {
        personal = {
          isDefault = true;
          settings = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          };

          userChrome = ''
            @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");

            #TabsToolbar {
              visibility: collapse;
            }

            #titlebar {
              display: none;
            }

            #sidebar-header {
              display: none;
            }
          '';
        };
        work = {
          isDefault = false;
          settings = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          };

          userChrome = ''
            @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");

            #TabsToolbar {
              visibility: collapse;
            }

            #titlebar {
              display: none;
            }

            #sidebar-header {
              display: none;
            }
          '';
        };
      };
    };
    git = {
      enable = true;
      delta.enable = true;
      userName = "rakanalh";
      userEmail = "rakan.alhneiti@gmail.com";
      signing.signByDefault = true;
      signing.key = "E565B55AACE73E69DBAE87C89981A6DBFDC453AE";
      aliases = {
        lol = "log --graph --decorate --oneline --abbrev-commit";
        lola = "log --graph --decorate --oneline --abbrev-commit --all";
        hist =
          "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
      };
      extraConfig = {
        pull.ff = "only";
        merge.conflictstyle = "diff3";
      };
    };
    rofi = {
      enable = true;
      theme = "Arc-Dark";
      pass.enable = true;
      pass.extraConfig = ''
        AUTOTYPE_field='pass' 
      '';
      plugins = [
        pkgs.rofi-calc
        pkgs.rofi-emoji
        pkgs.rofi-power-menu
        pkgs.rofi-pulse-select
      ];
    };
    tmux = {
      enable = true;
      prefix = "C-a";
      plugins = with pkgs; [
        tmuxPlugins.cpu
        tmuxPlugins.yank
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = "set -g @resurrect-processes 'vi vim nvim emacs man less more tail top htop irssi vagrant ssh mysql psql'";
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '60' # minutes
          '';
        }
        {
          plugin = tmuxPlugins.copycat;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '60' # minutes
          '';
        }
      ];
      extraConfig = ''
        set-window-option -g pane-base-index 1
        set -g base-index 1
        set -g mode-keys vi
        set -g detach-on-destroy off
        set -g history-limit 100000

        ## Mouse
        set -g mouse on
        set -g @scroll-speed-num-lines-per-scroll "0.5"

        ## Allow the arrow key to be used immediately after changing windows.
        set-option -g repeat-time 0

        ## Automatically set window title
        set-window-option -g automatic-rename on
        set-option -g set-titles on

        ## Window activity monitor
        setw -g monitor-activity on
        set -g visual-activity on

        # Keybindings
        ## New Shell
        bind-key Enter new "${pkgs.zsh}/bin/zsh"

        ## Easy clear history
        bind-key L clear-history

        ## Jump quickly into search
        bind-key / copy-mode \; send-key ?

        ## Set easier window split keys
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind _ split-window -fv -c "#{pane_current_path}"
        unbind '"'
        unbind %
        ## Windows
        bind c new-window -c "#{pane_current_path}"
        bind -n S-Left previous-window
        bind -n S-Right next-window

        ## Panes
        ### Movement
        bind k select-pane -U
        bind j select-pane -D
        bind l select-pane -R
        bind h select-pane -L
        bind u select-pane -t .-1 \;  resize-pane -Z
        bind o select-pane -t .+1 \;  resize-pane -Z

        ## Multi-Key sequences
        ### Resizing
        bind -T paneResize k resize-pane -U "10" \; switch-client -T paneResize
        bind -T paneResize j resize-pane -D "10" \; switch-client -T paneResize
        bind -T paneResize l resize-pane -R "10" \; switch-client -T paneResize
        bind -T paneResize h resize-pane -L "10" \; switch-client -T paneResize
        bind r switch-client -T paneResize

        ### Help
        bind -T helpKeys l list-keys
        bind -T kelpKeys r source-file ~/.tmux.conf \; display-message "tmux.conf reloaded."
        bind t switch-client -T helpKeys

        ## History
        bind -n C-k clear-history

        ## Mouse
        unbind -T copy-mode-vi MouseDragEnd1Pane
        ### Don't scroll down after yank
        bind-key -T copy-mode-vi y send-keys -X copy-pipe "xsel -ib" \; send-keys -X clear-selection
        bind-key -T copy-mode-vi Y send-keys -X copy-pipe-and-cancel "tmux paste-buffer"
        #bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'select-pane -t=; copy-mode -e; send-keys -M'"
        #bind -n WheelDownPane select-pane -t= \; send-keys -M

        ######################
        ### DESIGN CHANGES ###
        ######################

        # panes
        set -g pane-border-style fg=black
        set -g pane-active-border-style fg=brightred

        ## Status bar design
        # status line
        set -g status-justify left
        set -g status-bg default
        set -g status-fg colour12
        set -g status-interval 2

        # messaging
        set -g message-style fg=black,bg=yellow
        set -g message-command-style fg=blue,bg=black

        #window mode
        setw -g mode-style bg=colour6,fg=colour0

        # window status
        setw -g window-status-format " #F#I:#W#F "
        setw -g window-status-current-format " #F#I:#W#F "
        setw -g window-status-format "#[fg=magenta]#[bg=black] #I #[bg=cyan]#[fg=colour8] #W "
        setw -g window-status-current-format "#[bg=brightmagenta]#[fg=colour8] #I #[fg=colour8]#[bg=colour14] #W "
        setw -g window-status-current-style bg=colour0,fg=colour11,dim
        setw -g window-status-style bg=green,fg=black,reverse

        # Info on left (I don't have a session display for now)
        set -g status-left ""

        # loud or quiet?
        set-option -g visual-activity off
        set-option -g visual-bell off
        set-option -g visual-silence off
        set-window-option -g monitor-activity off
        set-option -g bell-action none

        set -g default-terminal "screen-256color"

        # The modes {
        setw -g clock-mode-colour colour135
        setw -g mode-style fg=colour196,bg=colour238,bold

        # }
        # The panes {

        set -g pane-border-style bg=colour235,fg=colour238,
        set -g pane-active-border-style bg=colour236,fg=colour51

        # }
        # The statusbar {

        set -g status-position bottom
        set -g status-style bg=colour234,fg=colour137,dim
        set -g status-left ""
        set -g status-right '#[fg=color233,bg=color=245,bold] CPU: #{cpu_percentage} #[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S '
        set -g status-right-length 50
        set -g status-left-length 20

        setw -g window-status-current-style fg=colour81,bg=colour238,bold
        setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F '

        setw -g window-status-style fg=colour138,bg=colour235,none
        setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '

        setw -g window-status-bell-style fg=colour255,bg=colour1,bold

        # }
        # The messages {

        set -g message-style fg=colour232,bg=colour166,bold
      '';
    };
    fzf.enable = true;
    vscode.enable = true;
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      oh-my-zsh.enable = true;
      oh-my-zsh.theme = "fox";
      envExtra = ''
        PATH=''${PATH}:~/.cargo/bin
        if [[ -n $IN_NIX_SHELL ]]; then
           export PS1=''${PS1//\%M/\%M-shell}
        fi
        RUSTC_WRAPPER=~/.cargo/bin/cachepot

        bindkey -e
        bindkey '[C' forward-word
        bindkey '[D' backward-word
        bindkey \^U backward-kill-line
      '';
      shellAliases = {
        # exa
        ls = "${pkgs.exa}/bin/exa";
        ll = "${pkgs.exa}/bin/exa -l";
        la = "${pkgs.exa}/bin/exa -a";
        lt = "${pkgs.exa}/bin/exa --tree";
        lla = "${pkgs.exa}/bin/exa -la";

        # git
        gs = "${pkgs.git}/bin/git status";

        # bat
        cat = "${pkgs.bat}/bin/bat";
      };
      plugins = [
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.5.0";
            sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
          };
        }
      ];
    };
    password-store = {
        enable = true;
        settings = {
          PASSWORD_STORE_DIR = "$HOME/.password-store";
        };
    };
    gpg = {
      enable = true;
      settings = {
        default-key = "BA80A7DBD120886D254C5854CBA62CDD373CF02E";
      };
    };
  };

  services = {
    emacs = {
      enable = true;
      package = doom-emacs;
    };
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      extraConfig = ''
        allow-emacs-pinentry
        allow-loopback-pinentry
      '';
      sshKeys = [
        "BA80A7DBD120886D254C5854CBA62CDD373CF02E"
        "E565B55AACE73E69DBAE87C89981A6DBFDC453AE"
      ];
    };
    flameshot = {
      enable = true;
    };
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
    };
  };
}
