return {
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            table.insert(opts.ensure_installed, "black")
        end
    },
    {
        "stevearc/conform.nvim",
        opts = {formatters_by_ft = {["python"] = {"black"}}}
    }
}
