{ pkgs, ... }:

let
  gpNvim = pkgs.vimUtils.buildVimPlugin {
    pname = "gp.nvim";
    version = "unstable";

    src = pkgs.fetchFromGitHub {
      owner = "robitx";
      repo = "gp.nvim";

      rev = "c37f154b97690c4925fef4e35ffdbf2c844b5f4e";
      hash = "sha256-+K536d3WF5eHRTSgkhn1NLFHms67iw4A0Ql8OZ9TgTw=";

    };
  };

  nvimPlugins = with pkgs.vimPlugins; [
    plenary-nvim
    nui-nvim
    nvim-web-devicons

    neo-tree-nvim
    nvim-lsp-file-operations

    nvim-lspconfig

    nvim-cmp
    cmp-nvim-lsp
    luasnip
    cmp_luasnip

    rustaceanvim
  ];

  pluginPack = pkgs.linkFarm "nvim-plugin-pack" (
    map (plugin: {
      name = "pack/nix/start/${plugin.pname or plugin.name}";
      path = plugin;
    }) (nvimPlugins ++ [ gpNvim ])
  );

  nixInitVim = pkgs.writeText "init.vim" ''
    set packpath^=${pluginPack}

    ${builtins.readFile ./init.vim}
  '';
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  environment.etc."xdg/nvim/init.vim".source = nixInitVim;

  environment.systemPackages = with pkgs; [
    git
    ripgrep
    fd
    curl

    wl-clipboard

    clang-tools
    pyright
    gopls

    rust-analyzer
    rustc
    cargo
  ];
}
