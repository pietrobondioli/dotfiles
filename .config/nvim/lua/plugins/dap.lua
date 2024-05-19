return {
  "mfussenegger/nvim-dap",

  keys = {
    {
      "<leader>d<F5>",
      function()
        require("dap").continue()
      end,
      desc = "Continue",
    },
    {
      "<leader>d<F10>",
      function()
        require("dap").step_over()
      end,
      desc = "Step Over",
    },
    {
      "<leader>d<F11>",
      function()
        require("dap").step_into()
      end,
      desc = "Step Into",
    },
    {
      "<leader>d<F12>",
      function()
        require("dap").step_out()
      end,
      desc = "Step Out",
    },
  },
}
