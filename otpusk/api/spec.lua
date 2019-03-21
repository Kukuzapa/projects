-- vm-15-11-01.yaml
return {
  components = {
    schemas = {
      create_vacation_req = {
        properties = {
          begin_date = {
            example = "1983-01-07",
            format = "date",
            type = "string"
          },
          comment = {
            type = "string"
          },
          end_date = {
            example = "1983-01-28",
            format = "date",
            type = "string"
          },
          type = {
            type = "string"
          }
        },
        required = { "begin_date", "end_date" },
        type = "object"
      },
      users_req = {
        properties = {
          clid = {
            type = "string"
          },
          competenses = {
            type = "string"
          },
          isadmin = {
            type = "boolean"
          }
        },
        type = "object"
      },
      vacation_req = {
        properties = {
          comment = {
            type = "string"
          },
          name = {
            type = "string"
          },
          vacid = {
            type = "string"
          }
        },
        required = { "vacid" },
        type = "object"
      }
    }
  },
  info = {
    description = "vacation manager",
    title = "Менеджер отпусков",
    version = "0.1"
  },
  openapi = 3,
  paths = {
    ["/admin/comment"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "vacid",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "get vacation comments",
        tags = { "admin" }
      },
      post = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
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
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/vacation_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "set vacation comment",
        tags = { "admin" }
      }
    },
    ["/admin/cross"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "vacid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "clid",
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
        summary = "vacation cross",
        tags = { "admin" }
      }
    },
    ["/admin/find"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "clname",
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
        summary = "find client",
        tags = { "admin" }
      }
    },
    ["/admin/history"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "clname",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "count",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "page",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "limit",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "get old vacations list",
        tags = { "admin" }
      }
    },
    ["/admin/link"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "vacid",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "work with link",
        tags = { "admin" }
      }
    },
    ["/admin/list"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "clid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "clname",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "count",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "page",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "limit",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "get current vacations list",
        tags = { "admin" }
      }
    },
    ["/admin/log"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "vacid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "count",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "page",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "limit",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "clname",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "get log",
        tags = { "admin" }
      }
    },
    ["/admin/new"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "clname",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "count",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "page",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "limit",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "get new vacations list",
        tags = { "admin" }
      }
    },
    ["/admin/user"] = {
      post = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
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
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/users_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "set admins and competenses",
        tags = { "admin" }
      }
    },
    ["/admin/users"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "clid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "clname",
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
        summary = "get users list",
        tags = { "admin" }
      }
    },
    ["/admin/vacation/{command}"] = {
      post = {
        parameters = { {
            ["in"] = "path",
            name = "command",
            required = true,
            schema = {
              enum = { "accept", "reject" },
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "userid",
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
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/vacation_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "vacation decision",
        tags = { "admin" }
      }
    },
    ["/admin/vacations"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "clid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "period",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "get count and vacation type",
        tags = { "admin" }
      }
    },
    ["/user/comment"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "vacid",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "get vacation comments",
        tags = { "user" }
      },
      post = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
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
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/vacation_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "set vacation comment",
        tags = { "user" }
      }
    },
    ["/user/get"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "email",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "name",
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
    ["/user/history"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
            required = true,
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
        summary = "vacation list",
        tags = { "user" }
      }
    },
    ["/user/list"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
            required = true,
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
        summary = "vacation list",
        tags = { "user" }
      }
    },
    ["/user/login"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "token",
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
            name = "userid",
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
        summary = "login",
        tags = { "user" }
      }
    },
    ["/user/vacation/cancel"] = {
      post = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
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
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/vacation_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "cancel vacation",
        tags = { "user" }
      }
    },
    ["/user/vacation/{command}"] = {
      post = {
        parameters = { {
            ["in"] = "path",
            name = "command",
            required = true,
            schema = {
              enum = { "check", "send" },
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "userid",
            schema = {
              type = "string"
            }
          } },
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/create_vacation_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "create vacation",
        tags = { "user" }
      }
    },
    ["/user/vacations"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "userid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "clid",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "period",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "get count and vacation type",
        tags = { "user" }
      }
    }
  },
  servers = { {
      url = "http://localhost/vm"
    } }
}