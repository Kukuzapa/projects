-- am-14-11-01.yaml
return {
  components = {
    schemas = {
      file = {
        properties = {
          filename = {
            format = "binary",
            type = "string"
          },
          id = {
            type = "string"
          },
          node = {
            type = "string"
          },
          token = {
            type = "string"
          },
          type = {
            type = "string"
          }
        },
        type = "object"
      },
      file_remove = {
        properties = {
          file = {
            type = "string"
          },
          id = {
            type = "string"
          },
          token = {
            type = "string"
          },
          type = {
            type = "string"
          }
        },
        type = "object"
      },
      node_add_req = {
        properties = {
          chld = {
            type = "string"
          },
          comment = {
            type = "string"
          },
          email = {
            type = "string"
          },
          files = {
            type = "string"
          },
          id = {
            type = "string"
          },
          password = {
            type = "string"
          },
          prnt = {
            type = "string"
          },
          url = {
            type = "string"
          }
        },
        type = "object"
      },
      node_remove_req = {
        properties = {
          id = {
            type = "string"
          },
          node = {
            type = "string"
          }
        },
        type = "object"
      },
      node_replace_req = {
        properties = {
          id = {
            type = "string"
          },
          node = {
            type = "string"
          },
          prnt = {
            type = "string"
          }
        },
        type = "object"
      },
      node_role_req = {
        properties = {
          id = {
            type = "string"
          },
          node = {
            type = "string"
          },
          role = {
            additionalProperties = {
              type = "string"
            },
            type = "object"
          }
        },
        type = "object"
      },
      node_update_req = {
        properties = {
          comment = {
            type = "string"
          },
          email = {
            type = "string"
          },
          files = {
            type = "string"
          },
          id = {
            type = "string"
          },
          node = {
            type = "string"
          },
          password = {
            type = "string"
          },
          url = {
            type = "string"
          }
        },
        type = "object"
      },
      node_user_req = {
        properties = {
          id = {
            type = "string"
          },
          node = {
            type = "string"
          },
          user = {
            additionalProperties = {
              type = "string"
            },
            type = "object"
          }
        },
        type = "object"
      },
      role_add_req = {
        properties = {
          id = {
            type = "string"
          },
          manager = {
            type = "string"
          },
          role = {
            type = "string"
          }
        },
        type = "object"
      },
      role_manager_req = {
        properties = {
          id = {
            type = "string"
          },
          manager = {
            items = {
              type = "string"
            },
            type = "array"
          },
          role = {
            type = "string"
          }
        },
        type = "object"
      },
      role_node_req = {
        properties = {
          id = {
            type = "string"
          },
          node = {
            additionalProperties = {
              type = "string"
            },
            type = "object"
          },
          role = {
            type = "string"
          }
        },
        type = "object"
      },
      role_remove_req = {
        properties = {
          id = {
            type = "string"
          },
          role = {
            type = "string"
          }
        },
        type = "object"
      },
      role_useraddrem_req = {
        properties = {
          id = {
            type = "string"
          },
          role = {
            type = "string"
          },
          user = {
            items = {
              type = "string"
            },
            minItems = 1,
            type = "array"
          }
        },
        type = "object"
      },
      user_add_req = {
        properties = {
          exp_date = {
            format = "date",
            type = "string"
          },
          id = {
            type = "string"
          },
          name = {
            type = "string"
          },
          role = {
            type = "string"
          }
        },
        required = { "id", "name" },
        type = "object"
      },
      user_node_req = {
        properties = {
          id = {
            type = "string"
          },
          name = {
            type = "string"
          },
          node = {
            additionalProperties = {
              type = "string"
            },
            type = "object"
          }
        },
        type = "object"
      },
      user_remove_req = {
        properties = {
          id = {
            type = "string"
          },
          name = {
            items = {
              type = "string"
            },
            minItems = 1,
            type = "array"
          }
        },
        required = { "id", "name" },
        type = "object"
      },
      user_role_req = {
        properties = {
          id = {
            type = "string"
          },
          name = {
            type = "string"
          },
          role = {
            items = {
              type = "string"
            },
            type = "array"
          }
        },
        type = "object"
      }
    }
  },
  info = {
    description = "access manager",
    title = "Менеджер паролей",
    version = "0.1"
  },
  openapi = 3,
  paths = {
    ["/base/node"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "id",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "grnt",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "get node id",
        tags = { "base" }
      }
    },
    ["/base/role"] = {
      get = {
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "get roles list",
        tags = { "base" }
      }
    },
    ["/base/tree"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "id",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "get tree",
        tags = { "base" }
      }
    },
    ["/base/user"] = {
      get = {
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "get users list",
        tags = { "base" }
      }
    },
    ["/file/add"] = {
      post = {
        requestBody = {
          content = {
            ["multipart/form-data"] = {
              schema = {
                ["$ref"] = "#/components/schemas/file"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "add file",
        tags = { "file" }
      }
    },
    ["/file/list"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "id",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "node",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "type",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "file list",
        tags = { "file" }
      }
    },
    ["/file/remove"] = {
      post = {
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/file_remove"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "add file",
        tags = { "file" }
      }
    },
    ["/find"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "id",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "token",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "value",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "object",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "find object",
        tags = { "find" }
      }
    },
    ["/front"] = {
      get = {
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "front",
        tags = { "front" }
      }
    },
    ["/hello"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "token",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "user",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "id",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "email",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "hello",
        tags = { "test" }
      }
    },
    ["/node/add"] = {
      post = {
        parameters = { {
            ["in"] = "query",
            name = "token",
            schema = {
              type = "string"
            }
          } },
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/node_add_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "add node",
        tags = { "node" }
      }
    },
    ["/node/get"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "id",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "node",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "token",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "get node info",
        tags = { "node" }
      }
    },
    ["/node/remove"] = {
      post = {
        parameters = { {
            ["in"] = "query",
            name = "token",
            schema = {
              type = "string"
            }
          } },
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/node_remove_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "remove node",
        tags = { "node" }
      }
    },
    ["/node/replace"] = {
      post = {
        parameters = { {
            ["in"] = "query",
            name = "token",
            schema = {
              type = "string"
            }
          } },
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/node_replace_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "replace node",
        tags = { "node" }
      }
    },
    ["/node/role"] = {
      post = {
        parameters = { {
            ["in"] = "query",
            name = "token",
            schema = {
              type = "string"
            }
          } },
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/node_role_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "node role grant",
        tags = { "node" }
      }
    },
    ["/node/tree"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "id",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "token",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "get tree",
        tags = { "node" }
      }
    },
    ["/node/update"] = {
      post = {
        parameters = { {
            ["in"] = "query",
            name = "token",
            schema = {
              type = "string"
            }
          } },
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/node_update_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "update node",
        tags = { "node" }
      }
    },
    ["/node/user"] = {
      post = {
        parameters = { {
            ["in"] = "query",
            name = "token",
            schema = {
              type = "string"
            }
          } },
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/node_user_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "node user grant",
        tags = { "node" }
      }
    },
    ["/role/add"] = {
      post = {
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/role_add_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "add role",
        tags = { "role" }
      }
    },
    ["/role/get"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "id",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "role",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "token",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "get role info",
        tags = { "role" }
      }
    },
    ["/role/list"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "id",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "get roles list",
        tags = { "role" }
      }
    },
    ["/role/manager"] = {
      post = {
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/role_manager_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "add/rem manger to role",
        tags = { "role" }
      }
    },
    ["/role/node"] = {
      post = {
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/role_node_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "add node's grants to role",
        tags = { "role" }
      }
    },
    ["/role/remove"] = {
      post = {
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/role_remove_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "remove role",
        tags = { "role" }
      }
    },
    ["/role/useradd"] = {
      post = {
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/role_useraddrem_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "add user into role",
        tags = { "role" }
      }
    },
    ["/role/userrem"] = {
      post = {
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/role_useraddrem_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "remove user from role",
        tags = { "role" }
      }
    },
    ["/user/add"] = {
      post = {
        parameters = { {
            ["in"] = "query",
            name = "token",
            schema = {
              type = "string"
            }
          } },
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/user_add_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "add user",
        tags = { "user" }
      }
    },
    ["/user/get"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "id",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "user",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "name",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "email",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "get user info",
        tags = { "user" }
      }
    },
    ["/user/node"] = {
      post = {
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/user_node_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "user's node grants",
        tags = { "user" }
      }
    },
    ["/user/remove"] = {
      post = {
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/user_remove_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "remove user",
        tags = { "user" }
      }
    },
    ["/user/role"] = {
      post = {
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/user_role_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "user's roles",
        tags = { "user" }
      }
    }
  },
  servers = { {
      url = "http://localhost:8081/am"
    } }
}