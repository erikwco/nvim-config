-- AWS Certified Developer – Associate (DVA-C02) en Neovim.
-- Explorador de cuenta (sustituto del AWS Toolkit de VS Code) + edición SAM/CFN.
-- Companion de estudio: Grok + MCP `aws-docs` (sin Amazon Q).
--
-- Atajos: <leader>A*  (A mayúscula; <leader>a queda para Sidekick/Grok)
-- En buffers del explorador: <CR> abre detalle, F filtra, R refresca.
-- `dd` de borrar está desactivado a propósito (labs sandbox).

local function is_cfn_head(text)
  return text:find("AWSTemplateFormatVersion", 1, true) or text:find("AWS::Serverless-2016-10-31", 1, true)
end

local function detect_cfn(path, bufnr)
  if not path or path == "" then
    return
  end
  local ext = path:match("%.([%w]+)$")
  if ext ~= "yaml" and ext ~= "yml" and ext ~= "json" then
    return
  end
  local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, 0, 40, false)
  if not ok or not lines then
    return
  end
  if not is_cfn_head(table.concat(lines, "\n")) then
    return
  end
  if ext == "json" then
    return "json.cloudformation"
  end
  return "yaml.cloudformation"
end

vim.filetype.add({
  extension = {
    template = "yaml.cloudformation",
    cfn = "yaml.cloudformation",
  },
  pattern = {
    [".*%.cfn%.ya?ml"] = "yaml.cloudformation",
    [".*%.cfn%.json"] = "json.cloudformation",
    [".*%.sam%.ya?ml"] = "yaml.cloudformation",
    [".*%.sam%.json"] = "json.cloudformation",
    [".*%.ya?ml"] = detect_cfn,
    [".*%.json"] = detect_cfn,
  },
})

vim.treesitter.language.register("yaml", "yaml.cloudformation")
vim.treesitter.language.register("json", "json.cloudformation")

-- Tags intrínsecos de CloudFormation/SAM para que yamlls no marque !Ref/!Sub como error.
local cfn_yaml_tags = {
  "!Ref",
  "!Sub",
  "!Sub sequence",
  "!GetAtt",
  "!GetAZs",
  "!ImportValue",
  "!Base64",
  "!Cidr",
  "!FindInMap sequence",
  "!Join sequence",
  "!Select sequence",
  "!Split sequence",
  "!And sequence",
  "!Equals sequence",
  "!If sequence",
  "!Not sequence",
  "!Or sequence",
  "!Condition",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "yaml" })
    end,
  },

  {
    "mason-org/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "cfn-lint" })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        yamlls = {
          filetypes = {
            "yaml",
            "yaml.docker-compose",
            "yaml.gitlab",
            "yaml.helm-values",
            "yaml.cloudformation",
          },
          settings = {
            yaml = {
              -- SchemaStore (extra lang.yaml) ya mapea template.yaml / *.sam.yaml / *.cf.yaml.
              customTags = cfn_yaml_tags,
            },
          },
        },
        jsonls = {
          filetypes = { "json", "jsonc", "json.cloudformation" },
        },
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft["yaml.cloudformation"] = { "cfn_lint" }
      opts.linters_by_ft["json.cloudformation"] = { "cfn_lint" }
      -- Archivo en disco (no stdin): SAM detecta el Transform por el path.
      opts.linters = opts.linters or {}
      opts.linters.cfn_lint = vim.tbl_deep_extend("force", opts.linters.cfn_lint or {}, {
        stdin = false,
      })
    end,
  },

  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>A", group = "aws", icon = "" },
      },
    },
  },

  {
    "jugarpeupv/aws.nvim",
    cmd = {
      "AwsPicker",
      "AwsLambda",
      "AwsS3",
      "AwsCW",
      "AwsCF",
      "AwsAGW",
      "AwsDDB",
      "AwsIAM",
      "AwsSM",
      "AwsECS",
      "AwsVPC",
      "AwsACM",
      "AwsCFront",
    },
    keys = {
      { "<leader>Ap", "<cmd>AwsPicker<cr>", desc = "AWS picker" },
      { "<leader>Al", "<cmd>AwsLambda<cr>", desc = "AWS Lambda" },
      { "<leader>As", "<cmd>AwsS3<cr>", desc = "AWS S3" },
      { "<leader>Aw", "<cmd>AwsCW<cr>", desc = "AWS CloudWatch" },
      { "<leader>Af", "<cmd>AwsCF<cr>", desc = "AWS CloudFormation" },
      { "<leader>Ag", "<cmd>AwsAGW<cr>", desc = "AWS API Gateway" },
      { "<leader>Ad", "<cmd>AwsDDB<cr>", desc = "AWS DynamoDB" },
      { "<leader>Ai", "<cmd>AwsIAM<cr>", desc = "AWS IAM" },
      { "<leader>Am", "<cmd>AwsSM<cr>", desc = "AWS Secrets Manager" },
      { "<leader>Ae", "<cmd>AwsECS<cr>", desc = "AWS ECS" },
      { "<leader>Av", "<cmd>AwsVPC<cr>", desc = "AWS VPC" },
    },
    opts = {
      -- Deja profile/region al AWS CLI (~/.aws/config, env, SSO).
      keymaps = {
        cloudformation = { delete = false },
        s3 = { delete = false, empty = false },
        cloudwatch = { delete = false },
        lambda = { delete = false },
        acm = { delete = false },
        secretsmanager = { delete = false },
      },
    },
    config = function(_, opts)
      require("aws").setup(opts)
    end,
  },
}
