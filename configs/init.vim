" ------------------------------------------------
" Appearance
" ------------------------------------------------

highlight Normal guibg=NONE ctermbg=NONE
highlight NormalNC guibg=NONE ctermbg=NONE

" Clear background of end-of-buffer tildes
highlight EndOfBuffer guibg=NONE ctermbg=NONE

" Line numbers / signs / folds
highlight LineNr guibg=NONE ctermbg=NONE
highlight SignColumn guibg=NONE ctermbg=NONE
highlight FoldColumn guibg=NONE ctermbg=NONE

" Floating windows
highlight NormalFloat guibg=NONE ctermbg=NONE
highlight FloatBorder guibg=NONE ctermbg=NONE

set number
set relativenumber
syntax on

" ------------------------------------------------
" General
" ------------------------------------------------

" Toggle Neo-tree with Ctrl+N
nnoremap <silent> <C-n> :Neotree toggle filesystem left<CR>

set mouse=a
set ttimeoutlen=5
set clipboard=unnamedplus
set backspace=indent,eol,start
set autoread

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab


lua << EOF

--------------------------------------------------
-- Neo-tree
--------------------------------------------------

require("neo-tree").setup({
    close_if_last_window = true,

    enable_git_status = true,
    enable_diagnostics = true,

    sources = {
        "filesystem",
        "buffers",
        "git_status",
    },

    source_selector = {
        winbar = true,
        statusline = false,
    },

    filesystem = {
        bind_to_cwd = false,

        follow_current_file = {
            enabled = true,
            leave_dirs_open = false,
        },

        use_libuv_file_watcher = true,

        hijack_netrw_behavior = "open_default",

        filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = false,
        },
    },

    default_component_configs = {
        indent = {
            indent_size = 2,
            padding = 1,
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
            with_expanders = nil,
            expander_collapsed = "",
            expander_expanded = "",
        },

        icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "󰜌",
            default = "*",
            highlight = "NeoTreeFileIcon",
        },

        modified = {
            symbol = "[+]",
            highlight = "NeoTreeModified",
        },

        diagnostics = {
            symbols = {
                hint = "H",
                info = "I",
                warn = "W",
                error = "E",
            },

            highlights = {
                hint = "DiagnosticSignHint",
                info = "DiagnosticSignInfo",
                warn = "DiagnosticSignWarn",
                error = "DiagnosticSignError",
            },
        },

        git_status = {
            symbols = {
                added = "+",
                modified = "~",
                deleted = "x",
                renamed = "r",
                untracked = "?",
                ignored = "i",
                unstaged = "u",
                staged = "s",
                conflict = "!",
            },
        },
    },

    window = {
        position = "left",
        width = 35,

        mappings = {
            ["<space>"] = "none",
            ["<CR>"] = "open",
            ["l"] = "open",
            ["h"] = "close_node",
            ["S"] = "open_split",
            ["s"] = "open_vsplit",
            ["t"] = "open_tabnew",
            ["a"] = "add",
            ["A"] = "add_directory",
            ["d"] = "delete",
            ["r"] = "rename",
            ["c"] = "copy",
            ["m"] = "move",
            ["R"] = "refresh",
            ["?"] = "show_help",
        },
    },
})

--------------------------------------------------
-- LSP-aware file operations
--------------------------------------------------

require("lsp-file-operations").setup()

--------------------------------------------------
-- LSP capabilities
--------------------------------------------------

local capabilities =
    require("cmp_nvim_lsp").default_capabilities()

--------------------------------------------------
-- LSP setup
--------------------------------------------------

vim.lsp.config("clangd", {
    capabilities = capabilities,
})

vim.lsp.config("pyright", {
    capabilities = capabilities,
})

vim.lsp.config("gopls", {
    capabilities = capabilities,
})

vim.lsp.enable({
    "clangd",
    "pyright",
    "gopls",
})

-- Rust is handled by rustaceanvim.

--------------------------------------------------
-- Completion: nvim-cmp
--------------------------------------------------

local cmp = require("cmp")

cmp.setup({
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },

    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),

        ["<CR>"] = cmp.mapping.confirm({
            select = true,
        }),

        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    }),

    sources = cmp.config.sources({
        {
            name = "nvim_lsp",
        },
        {
            name = "luasnip",
        },
    }),
})

--------------------------------------------------
-- LSP diagnostics
--------------------------------------------------

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,

    float = {
        border = "rounded",
        source = true,
    },
})

--------------------------------------------------
-- LSP keymaps
--------------------------------------------------

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufnr = args.buf

        local opts = {
            silent = true,
            buffer = bufnr,
        }

        vim.keymap.set(
            "n",
            "K",
            vim.lsp.buf.hover,
            opts
        )

        vim.keymap.set(
            "n",
            "gd",
            vim.lsp.buf.definition,
            opts
        )

        vim.keymap.set(
            "n",
            "gr",
            vim.lsp.buf.references,
            opts
        )

        vim.keymap.set(
            "n",
            "gi",
            vim.lsp.buf.implementation,
            opts
        )

        vim.keymap.set(
            "n",
            "rn",
            vim.lsp.buf.rename,
            opts
        )

        vim.keymap.set(
            "n",
            "ca",
            vim.lsp.buf.code_action,
            opts
        )

        vim.keymap.set(
            "n",
            "gl",
            vim.diagnostic.open_float,
            opts
        )

        vim.keymap.set(
            "n",
            "[d",
            vim.diagnostic.goto_prev,
            opts
        )

        vim.keymap.set(
            "n",
            "]d",
            vim.diagnostic.goto_next,
            opts
        )
    end,
})

--------------------------------------------------
-- gp.nvim: OpenAI provider
--------------------------------------------------

local openai_model = os.getenv("OPENAI_MODEL")

if openai_model == nil or openai_model == "" then
    openai_model = "gpt-5.4-mini"
end

local gp_config = {
    providers = {
        openai = {
            disable = false,
            endpoint = "https://api.openai.com/v1/chat/completions",
            secret = "",
        },

        azure = {
            disable = true,
        },
    },

    agents = {
        {
            name = "OpenAI",
            provider = "openai",

            chat = true,
            command = true,

            model = {
                model = openai_model,
                temperature = 0.2,
                top_p = 1,
            },

            system_prompt =
                require("gp.defaults").chat_system_prompt,
        },
    },

    default_chat_agent = "OpenAI",
    default_command_agent = "OpenAI",

    log_file =
        vim.fn.stdpath("log"):gsub("/$", "")
        .. "/gp.nvim.log",

    log_sensitive = false,
}

require("gp").setup(gp_config)

EOF
