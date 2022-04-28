{
  "targets": [
    {
      "target_name": "debugger",
      "sources": [
        "module.cxx",
        "debugger_wrap.cxx"
      ],
      'include_dirs': [
          '../../headers',
          '../../third_party/lua/lua'
        ], 
        'libraries': [
            '/home/stream/Downloads/gits/lua_mobdebug_server/mobdebug_wrapper/bindings/javascript/libmobdebug_wrapper.so'
        ],
        'link_settings': {
            'library_dirs': [
                '.'
            ]
        }
    }
  ]
}