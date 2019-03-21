-- 21-02-19-01.yaml
return {
  components = {
    parameters = {
      CDH_info_authInfo_req = {
        ["in"] = "query",
        name = "authInfo",
        schema = {
          ["$ref"] = "#/components/schemas/authinfo"
        }
      },
      NewPass_req = {
        ["in"] = "query",
        name = "newPass",
        schema = {
          ["$ref"] = "#/components/schemas/registrar_set_pass_req"
        }
      },
      contact_id_req = {
        ["in"] = "query",
        name = "id",
        required = true,
        schema = {
          ["$ref"] = "#/components/schemas/contact_id"
        }
      },
      curExpDate_req = {
        ["in"] = "query",
        name = "curExpDate",
        required = true,
        schema = {
          ["$ref"] = "#/components/schemas/curExpDate"
        }
      },
      domain_name_req = {
        ["in"] = "query",
        name = "name",
        required = true,
        schema = {
          oneOf = { {
              ["$ref"] = "#/components/schemas/domain_name_ru"
            }, {
              ["$ref"] = "#/components/schemas/domain_name_rf"
            } }
        }
      },
      tld_req = {
        ["in"] = "path",
        name = "tld",
        required = true,
        schema = {
          ["$ref"] = "#/components/schemas/tld"
        }
      },
      transfer_req = {
        ["in"] = "path",
        name = "transfer",
        required = true,
        schema = {
          ["$ref"] = "#/components/schemas/transfer"
        }
      }
    },
    schemas = {
      IPI_address = {
        maxLength = 510,
        minLength = 1,
        pattern = "^[a-zA-Z0-9]((?!##)(?!<)(?!>).)+$",
        type = "string"
      },
      IPI_name = {
        maxLength = 255,
        minLength = 1,
        pattern = "^[a-zA-Z0-9 -.']+$",
        type = "string"
      },
      IPI_org = {
        maxLength = 512,
        minLength = 1,
        pattern = "^[a-zA-Z0-9]((?!##)(?!<)(?!>).)+$",
        type = "string"
      },
      LPI_address = {
        maxLength = 510,
        minLength = 1,
        pattern = "^[а-яА-ЯёЁa-zA-Z0-9]((?!##)(?!<)(?!>).)+$",
        type = "string"
      },
      LPI_name = {
        maxLength = 255,
        minLength = 1,
        pattern = "^[а-яА-ЯёЁa-zA-Z0-9 -.']+$",
        type = "string"
      },
      LPI_org = {
        maxLength = 512,
        minLength = 1,
        pattern = "^[а-яА-ЯёЁa-zA-Z0-9]((?!##)(?!<)(?!>).)+$",
        type = "string"
      },
      authinfo = {
        maxLength = 32,
        minLength = 6,
        pattern = "^((?!##)(?!<)(?!>)(?![а-яА-ЯёЁ]).)+$",
        type = "string"
      },
      birthday = {
        pattern = "^([12]\\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\\d|3[01]))$",
        type = "string"
      },
      bln_type = {
        type = "boolean"
      },
      bool = {
        type = "boolean"
      },
      contact_create_req = {
        properties = {
          address = {
            items = {
              ["$ref"] = "#/components/schemas/LPI_address"
            },
            maxItems = 15,
            minItems = 1,
            type = "array"
          },
          birthday = {
            ["$ref"] = "#/components/schemas/birthday"
          },
          email = {
            items = {
              ["$ref"] = "#/components/schemas/email"
            },
            maxItems = 15,
            minItems = 1,
            type = "array"
          },
          int_name = {
            ["$ref"] = "#/components/schemas/IPI_name"
          },
          int_org = {
            ["$ref"] = "#/components/schemas/IPI_org"
          },
          leg_address = {
            items = {
              ["$ref"] = "#/components/schemas/LPI_address"
            },
            maxItems = 15,
            minItems = 1,
            type = "array"
          },
          name = {
            ["$ref"] = "#/components/schemas/LPI_name"
          },
          org = {
            ["$ref"] = "#/components/schemas/LPI_org"
          },
          passport = {
            items = {
              ["$ref"] = "#/components/schemas/passport"
            },
            maxItems = 15,
            minItems = 1,
            type = "array"
          },
          taxpayerNumbers = {
            ["$ref"] = "#/components/schemas/taxpayerNumbers"
          },
          voice = {
            items = {
              ["$ref"] = "#/components/schemas/voice"
            },
            maxItems = 15,
            minItems = 1,
            type = "array"
          }
        },
        required = { "voice", "email", "address" },
        type = "object"
      },
      contact_delete_req = {
        properties = {
          id = {
            ["$ref"] = "#/components/schemas/contact_id"
          }
        },
        type = "object"
      },
      contact_id = {
        maxLength = 32,
        minLength = 3,
        pattern = "^[a-zA-Z0-9-\\\\_]+$",
        type = "string"
      },
      contact_update_req = {
        properties = {
          address = {
            items = {
              ["$ref"] = "#/components/schemas/LPI_address"
            },
            maxItems = 15,
            minItems = 1,
            type = "array"
          },
          birthday = {
            ["$ref"] = "#/components/schemas/birthday"
          },
          email = {
            items = {
              ["$ref"] = "#/components/schemas/email"
            },
            maxItems = 15,
            minItems = 1,
            type = "array"
          },
          id = {
            ["$ref"] = "#/components/schemas/contact_id"
          },
          int_name = {
            ["$ref"] = "#/components/schemas/IPI_name"
          },
          int_org = {
            ["$ref"] = "#/components/schemas/IPI_org"
          },
          leg_address = {
            items = {
              ["$ref"] = "#/components/schemas/LPI_address"
            },
            maxItems = 15,
            minItems = 1,
            type = "array"
          },
          name = {
            ["$ref"] = "#/components/schemas/LPI_name"
          },
          org = {
            ["$ref"] = "#/components/schemas/LPI_org"
          },
          passport = {
            items = {
              ["$ref"] = "#/components/schemas/passport"
            },
            maxItems = 15,
            minItems = 1,
            type = "array"
          },
          status = {
            items = {
              enum = { "clientUpdateProhibited", "clientDeleteProhibited" },
              type = "string"
            },
            type = "array"
          },
          taxpayerNumbers = {
            ["$ref"] = "#/components/schemas/taxpayerNumbers"
          },
          voice = {
            items = {
              ["$ref"] = "#/components/schemas/voice"
            },
            maxItems = 15,
            minItems = 1,
            type = "array"
          }
        },
        required = { "id" },
        type = "object"
      },
      curExpDate = {
        format = "date",
        type = "string"
      },
      description = {
        maxLength = 250,
        minLength = 1,
        pattern = "^[a-zA-Z0-9]((?!##)(?!<)(?!>).)+$",
        type = "string"
      },
      domain_create_req = {
        properties = {
          authInfo = {
            ["$ref"] = "#/components/schemas/authinfo"
          },
          description = {
            ["$ref"] = "#/components/schemas/description"
          },
          name = {
            oneOf = { {
                ["$ref"] = "#/components/schemas/domain_name_ru"
              }, {
                ["$ref"] = "#/components/schemas/domain_name_rf"
              } }
          },
          ns = {
            additionalProperties = {
              oneOf = { {
                  ["$ref"] = "#/components/schemas/bln_type"
                }, {
                  ["$ref"] = "#/components/schemas/str_type"
                } }
            },
            type = "object"
          },
          registrant = {
            ["$ref"] = "#/components/schemas/contact_id"
          }
        },
        required = { "registrant", "name" },
        type = "object"
      },
      domain_delete_req = {
        properties = {
          name = {
            oneOf = { {
                ["$ref"] = "#/components/schemas/domain_name_ru"
              }, {
                ["$ref"] = "#/components/schemas/domain_name_rf"
              } }
          }
        },
        required = { "name" },
        type = "object"
      },
      domain_name_rf = {
        maxLength = 255,
        minLength = 1,
        pattern = "^[а-я0-9][а-я0-9-]{0,61}[а-я0-9]\\.(рф)$",
        type = "string"
      },
      domain_name_ru = {
        maxLength = 255,
        minLength = 1,
        pattern = "^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]\\.(ru)$",
        type = "string"
      },
      domain_renew_req = {
        properties = {
          curExpDate = {
            ["$ref"] = "#/components/schemas/curExpDate"
          },
          name = {
            oneOf = { {
                ["$ref"] = "#/components/schemas/domain_name_ru"
              }, {
                ["$ref"] = "#/components/schemas/domain_name_rf"
              } }
          }
        },
        required = { "name", "curExpDate" },
        type = "object"
      },
      domain_transfer_req = {
        properties = {
          authInfo = {
            ["$ref"] = "#/components/schemas/authinfo"
          },
          name = {
            oneOf = { {
                ["$ref"] = "#/components/schemas/domain_name_ru"
              }, {
                ["$ref"] = "#/components/schemas/domain_name_rf"
              } }
          }
        },
        type = "object"
      },
      domain_update_req = {
        properties = {
          authInfo = {
            ["$ref"] = "#/components/schemas/authinfo"
          },
          description = {
            ["$ref"] = "#/components/schemas/description"
          },
          name = {
            oneOf = { {
                ["$ref"] = "#/components/schemas/domain_name_ru"
              }, {
                ["$ref"] = "#/components/schemas/domain_name_rf"
              } }
          },
          ns = {
            additionalProperties = {
              oneOf = { {
                  ["$ref"] = "#/components/schemas/bln_type"
                }, {
                  ["$ref"] = "#/components/schemas/str_type"
                } }
            },
            type = "object"
          },
          registrant = {
            ["$ref"] = "#/components/schemas/contact_id"
          },
          status = {
            items = {
              enum = { "clientRenewProhibited", "clientUpdateProhibited", "clientTransferProhibited", "clientDeleteProhibited", "clientHold", "changeProhibited" },
              type = "string"
            },
            type = "array"
          }
        },
        required = { "name" },
        type = "object"
      },
      email = {
        maxLength = 255,
        minLength = 1,
        pattern = "^([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)*(\\(transfer\\)){0,1}$",
        type = "string"
      },
      fax = {
        maxLength = 255,
        minLength = 1,
        pattern = "^[\\d +()#-]+$",
        type = "string"
      },
      host_name = {
        maxLength = 255,
        minLength = 1,
        pattern = "^(?!:\\/\\/)([a-zA-Z0-9-_]+\\.)*[a-zA-Z0-9][a-zA-Z0-9-_]+\\.(ru|RU|Ru|rU)?$",
        type = "string"
      },
      ip = {
        oneOf = { {
            ["$ref"] = "#/components/schemas/v4"
          }, {
            ["$ref"] = "#/components/schemas/v6"
          } }
      },
      newPW = {
        maxLength = 32,
        minLength = 6,
        pattern = "^[\\x00-\\x7F]+$",
        type = "string"
      },
      passport = {
        maxLength = 255,
        minLength = 1,
        pattern = "^((?!##)(?!<)(?!>).)+$",
        type = "string"
      },
      registrar_set_pass_req = {
        properties = {
          newPW = {
            ["$ref"] = "#/components/schemas/newPW"
          }
        },
        required = { "newPW" },
        type = "object"
      },
      registrar_update_req = {
        properties = {
          ip = {
            items = {
              oneOf = { {
                  ["$ref"] = "#/components/schemas/v4"
                }, {
                  ["$ref"] = "#/components/schemas/v6"
                } }
            },
            maxItems = 20,
            minItems = 1,
            type = "array"
          }
        },
        required = { "ip" },
        type = "object"
      },
      str_type = {
        type = "string"
      },
      taxpayerNumbers = {
        maxLength = 27,
        minLength = 0,
        pattern = "^[0-9]{0,27}$",
        type = "string"
      },
      tld = {
        default = "ru",
        enum = { "ru", "rf" },
        type = "string"
      },
      transfer = {
        enum = { "request", "approve", "reject", "cancel", "ok" },
        type = "string"
      },
      v4 = {
        pattern = "^((\\d|[1-9]\\d|2[0-4]\\d|25[0-5]|1\\d\\d)(?:\\.(\\d|[1-9]\\d|2[0-4]\\d|25[0-5]|1\\d\\d)){3})$",
        type = "string"
      },
      v6 = {
        pattern = "^(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$",
        type = "string"
      },
      voice = {
        maxLength = 255,
        minLength = 1,
        pattern = "^[\\d +()#-]+(\\(transfer\\)|\\(sms\\)){0,1}$",
        type = "string"
      }
    }
  },
  info = {
    description = "обмен данными с реестром(тестовым)",
    title = "ТЦИ АПИ 2",
    version = "2.1"
  },
  openapi = 3,
  paths = {
    ["/base"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "query",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "reg",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "obj",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "namid",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Веб-интерфейс",
        tags = { "Front" }
      }
    },
    ["/contact/check/{tld}"] = {
      get = {
        parameters = { {
            ["$ref"] = "#/components/parameters/tld_req"
          }, {
            ["$ref"] = "#/components/parameters/contact_id_req"
          } },
        responses = {
          ["200"] = {
            description = "Успех"
          }
        },
        summary = "Проверяем занятьсть ID (?)",
        tags = { "Contact" }
      }
    },
    ["/contact/copy/{tld}"] = {
      get = {
        parameters = { {
            ["$ref"] = "#/components/parameters/tld_req"
          }, {
            ["$ref"] = "#/components/parameters/contact_id_req"
          }, {
            ["$ref"] = "#/components/parameters/CDH_info_authInfo_req"
          } },
        responses = {
          ["200"] = {
            description = "Успех"
          }
        },
        summary = "Обновление данных из реестра (?!)",
        tags = { "Contact" }
      }
    },
    ["/contact/create/{tld}"] = {
      post = {
        parameters = { {
            ["$ref"] = "#/components/parameters/tld_req"
          } },
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/contact_create_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Create contact person",
        tags = { "Contact" }
      }
    },
    ["/contact/delete/{tld}"] = {
      post = {
        parameters = { {
            ["$ref"] = "#/components/parameters/tld_req"
          }, {
            ["$ref"] = "#/components/parameters/contact_id_req"
          } },
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/contact_delete_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Удаляем contact (?)",
        tags = { "Contact" }
      }
    },
    ["/contact/get/{tld}"] = {
      get = {
        parameters = { {
            ["$ref"] = "#/components/parameters/tld_req"
          }, {
            ["$ref"] = "#/components/parameters/contact_id_req"
          }, {
            ["$ref"] = "#/components/parameters/CDH_info_authInfo_req"
          } },
        responses = {
          ["200"] = {
            description = "Успех"
          }
        },
        summary = "Информация о контакте (?)",
        tags = { "Contact" }
      }
    },
    ["/contact/update/{tld}"] = {
      post = {
        parameters = { {
            ["$ref"] = "#/components/parameters/tld_req"
          } },
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/contact_update_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Update contact person",
        tags = { "Contact" }
      }
    },
    ["/cron"] = {
      get = {
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Запуск крона",
        tags = { "Cron" }
      }
    },
    ["/domain/check"] = {
      get = {
        parameters = { {
            ["$ref"] = "#/components/parameters/domain_name_req"
          } },
        responses = {
          ["200"] = {
            description = "Успех"
          }
        },
        summary = "Проверяем занятьсть имени (?)",
        tags = { "Domain" }
      }
    },
    ["/domain/copy"] = {
      get = {
        parameters = { {
            ["$ref"] = "#/components/parameters/domain_name_req"
          }, {
            ["$ref"] = "#/components/parameters/CDH_info_authInfo_req"
          } },
        responses = {
          ["200"] = {
            description = "Успех"
          }
        },
        summary = "Обновление данных из реестра (?!)",
        tags = { "Domain" }
      }
    },
    ["/domain/create"] = {
      post = {
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/domain_create_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Создаем домен",
        tags = { "Domain" }
      }
    },
    ["/domain/delete"] = {
      post = {
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/domain_delete_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Удаляем домен",
        tags = { "Domain" }
      }
    },
    ["/domain/get"] = {
      get = {
        parameters = { {
            ["$ref"] = "#/components/parameters/domain_name_req"
          }, {
            ["$ref"] = "#/components/parameters/CDH_info_authInfo_req"
          } },
        responses = {
          ["200"] = {
            description = "Успех"
          }
        },
        summary = "Информация о домене (?)",
        tags = { "Domain" }
      }
    },
    ["/domain/renew"] = {
      post = {
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/domain_renew_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Продление домена",
        tags = { "Domain" }
      }
    },
    ["/domain/transfer/{transfer}"] = {
      post = {
        parameters = { {
            ["$ref"] = "#/components/parameters/transfer_req"
          } },
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/domain_transfer_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Передача домена",
        tags = { "Domain" }
      }
    },
    ["/domain/update"] = {
      post = {
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/domain_update_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Обновление домена",
        tags = { "Domain" }
      }
    },
    ["/getdata/{tld}"] = {
      get = {
        parameters = { {
            ["$ref"] = "#/components/parameters/tld_req"
          }, {
            ["in"] = "query",
            name = "page",
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
        summary = "Сохраненные сообщения от ТЦИ",
        tags = { "Front" }
      }
    },
    ["/history"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "per_from",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "per_to",
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
            name = "clid",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "История",
        tags = { "Front" }
      }
    },
    ["/list"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "column",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "dir",
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
            name = "domain",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "list of domain",
        tags = { "Front" }
      }
    },
    ["/panel/domain/check"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "domain_name",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "input_format",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "input_data",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "username",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "password",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "panel domain check",
        tags = { "panel" }
      }
    },
    ["/panel/domain/create"] = {
      post = {
        parameters = { {
            ["in"] = "query",
            name = "username",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "password",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "input_format",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "input_data",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "output_content_type",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "panel domain create",
        tags = { "panel" }
      }
    },
    ["/panel/domain/get_transfer_status"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "username",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "password",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "input_format",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "input_data",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "output_content_type",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "panel domain get transfer status",
        tags = { "panel" }
      }
    },
    ["/panel/domain/set_new_authinfo"] = {
      post = {
        parameters = { {
            ["in"] = "query",
            name = "username",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "password",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "authinfo",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "dname",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "output_content_type",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "panel domain set new authInfo",
        tags = { "panel" }
      }
    },
    ["/poll/{tld}"] = {
      get = {
        parameters = { {
            ["$ref"] = "#/components/parameters/tld_req"
          }, {
            ["in"] = "query",
            name = "page",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Сохраненные сообщения от ТЦИ",
        tags = { "Front" }
      }
    },
    ["/registrar/billing/{tld}"] = {
      get = {
        parameters = { {
            ["$ref"] = "#/components/parameters/tld_req"
          }, {
            ["in"] = "query",
            name = "billing",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "currency",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "date",
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
        summary = "Биллинг",
        tags = { "Registrar" }
      }
    },
    ["/registrar/get/{tld}"] = {
      get = {
        parameters = { {
            ["$ref"] = "#/components/parameters/tld_req"
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Информация о регистраторе (?)",
        tags = { "Registrar" }
      }
    },
    ["/registrar/hello/{tld}"] = {
      get = {
        parameters = { {
            ["$ref"] = "#/components/parameters/tld_req"
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Команда проверки связи",
        tags = { "Registrar" }
      }
    },
    ["/registrar/limits/{tld}"] = {
      get = {
        parameters = { {
            ["$ref"] = "#/components/parameters/tld_req"
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Лимиты",
        tags = { "Registrar" }
      }
    },
    ["/registrar/password/{tld}"] = {
      post = {
        parameters = { {
            ["$ref"] = "#/components/parameters/tld_req"
          }, {
            ["$ref"] = "#/components/parameters/NewPass_req"
          } },
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/registrar_set_pass_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Замена пароля регистратора на вход",
        tags = { "Registrar" }
      }
    },
    ["/registrar/poll/{tld}"] = {
      get = {
        parameters = { {
            ["$ref"] = "#/components/parameters/tld_req"
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Получение сообщений реестра (?)",
        tags = { "Registrar" }
      }
    },
    ["/registrar/stat/{tld}"] = {
      get = {
        parameters = { {
            ["$ref"] = "#/components/parameters/tld_req"
          }, {
            ["in"] = "query",
            name = "object",
            schema = {
              type = "string"
            }
          }, {
            ["in"] = "query",
            name = "pending",
            schema = {
              type = "string"
            }
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Статистика",
        tags = { "Registrar" }
      }
    },
    ["/registrar/update/{tld}"] = {
      post = {
        parameters = { {
            ["$ref"] = "#/components/parameters/tld_req"
          } },
        requestBody = {
          content = {
            ["application/json"] = {
              schema = {
                ["$ref"] = "#/components/schemas/registrar_update_req"
              }
            }
          }
        },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "Добавляем/убираем ip адреса регистратора (?)",
        tags = { "Registrar" }
      }
    },
    ["/sync/{tld}"] = {
      get = {
        parameters = { {
            ["in"] = "query",
            name = "domain",
            schema = {
              type = "string"
            }
          }, {
            ["$ref"] = "#/components/parameters/tld_req"
          } },
        responses = {
          ["200"] = {
            description = "OK"
          }
        },
        summary = "sync domain",
        tags = { "Front" }
      }
    }
  },
  servers = { {
      url = "http://84.38.3.34:8080/api/v2.1",
      variables = {
        user = {
          default = "user"
        }
      }
    } }
}