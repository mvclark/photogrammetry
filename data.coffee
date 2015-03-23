imageData = $blab.ctx.getImageData(0, 0, 512, 512) #;

d = imageData.data

f = (n, del) ->
    d[i] += del for i in [n..n+2]

f(k, -60) for k in [0...d.length] by 4

$blab.ctx.putImageData(imageData, 0, 0);


