export default {
  async fetch(request, env) {
    if (request.method == 'GET') {
      try {
        const code = request.url.split('/').pop();
        if (code){
          const value = await env.file.get(code)
          if (value == null) {
            return new Response("Value not found", {status: 404})
          }
          return new Response(value)
        }else{
          return new Response('Usage: curl -k -F "file=@文件" ' + request.url.slice(0, -1))
        }
      }catch (e){
        return new Response(e.message, {status: 500})
      }
    }

    if (request.method == 'POST') {
      try {
        const formData = await request.formData()
        const file = formData.get('file')
        if (file){
          const fileName = getName()
          await env.file.put(fileName, file.stream(), {expirationTtl: 300})
          return new Response('"link":"' + request.url + fileName + '"' )
        }else{
          return new Response('Usage: curl -k -F "file=@文件" ' + request.url.slice(0, -1))
        }
      }catch (e){
        return new Response(e.message, {status: 500})
      }
    }
  }
}

// 生成一个唯一的文件名
function getName() {
  let randomString = '';
  const alphabet = 'abcdefghijklmnopqrstuvwxyz'
  for (let i = 0; i < 5; i++) {
    randomString += alphabet.charAt(Math.floor(Math.random() * alphabet.length))
  }
  return randomString + Date.now()
}
