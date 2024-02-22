return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim", "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter", "nvim-neotest/neotest-go",
            "nvim-neotest/neotest-python", "nvim-neotest/neotest-jest",
            "marilari88/neotest-vitest", "thenbe/neotest-playwright",
            "rouge8/neotest-rust", "Issafalcon/neotest-dotnet",
            "andy-bell101/neotest-java", "rcasia/neotest-bash"
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-python")({dap = {justMyCode = false}}),
                    require("neotest-go"), require("neotest-jest"),
                    require("neotest-vitest"), require("neotest-playwright"),
                    require("neotest-rust"), require("neotest-dotnet"),
                    require("neotest-java"), require("neotest-bash")
                }
            })
        end
    }, {
        "andythigpen/nvim-coverage",
        config = function() require("coverage").setup() end
    }
}
