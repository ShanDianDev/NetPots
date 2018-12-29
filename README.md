# netpots

A Net Package

## Getting Started

How it use?

You can do it. Like this example.

_requestData() async {
    await (NetUtil()
          ..baseUrl = "http://image.baidu.com/"
          ..path = "channel/listjson"
          ..getPrams = {
            'tag1': '壁纸',
            'ie': 'utf-8',
            'tag2': '全部',
            'pn': '0',
            'rn': '60'
          }
          ..method = NetUtil.get)
        .call(onResponse: (response) {
      }
    });
}
   
