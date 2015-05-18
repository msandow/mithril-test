#fs = require('fs');
#path = require('path');
#exec = require('child_process').exec;
#async = require('async')
#cat = require('mapcat').cat
#path = require('path')
#UglifyJS = require("uglify-js")
#temp = require('temp').track()
console = require('./Console')

exec = require('child_process').exec;


module.exports = (webFilePath, diskFilePath, dev = true) ->
  webResponse = ''
  
  exec("#{__dirname}/../node_modules/.bin/browserify -d -t coffeeify #{diskFilePath}", (err, stdout, stderr)->
    console.error(err) if err
    
    webResponse = stdout
  )

  (req, res, next)->
    if req.method is 'GET' and req.originalUrl is webFilePath
      res.set('Content-Type', 'text/javascript').send(webResponse)
    
    next()

#module.exports = (webFilePath, appRoot, source) ->
#  topLevelDirs = []
#  cacheDir = ''
#  fileTime = new Date().getTime()
#  webDirName = path.dirname(webFilePath)
#  webDirName += '/' if webDirName[webDirName.length - 1] isnt '/'
#  webFilePath = path.basename(webFilePath)
#  mainJSFile = ''
#  mainMapFile = ''
#  mainSourceFiles = []
#  requireHash = {}
#  compiling = false
#  
#
#  escapeRegExp = (str) ->
#    str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")
#  
#  scanRootDirs = (cb = (->)) ->
#    fs.readdir(appRoot, (err, files)->
#      stats = []
#
#      for file in files when file[0] isnt '.'
#        do (file)->
#          stats.push(
#            (callback) ->
#              fs.stat("#{appRoot}/#{file}", (err, stat)->
#                callback(err, stat) if err
#
#                if stat.isDirectory()
#                  callback(null, file)
#                else
#                  callback(null, false)
#              )
#          )
#
#      async.series(stats,(err, results)->
#        errorMessage(err) if err
#
#        topLevelDirs = results.filter((i)->i)
#        cb()
#      )
#    )
#  
#  errorMessage = (msg = 'Undefined error message') ->
#    console.error(msg)
#    temp.cleanupSync()
#    process.exit(1)
#  
#  setUp = (cb = (->))->
#    temp.mkdir('__coffeeShotCache', (err, tempPath) ->
#      errorMessage(err) if err
#      
#      cacheDir = "#{tempPath}/"
#      cb()
#    )
#  
#  
#  tearDown = (cb = (->)) ->
#    temp.cleanup((err, stats)->
#      errorMessage(err) if err
#      cb()
#    )
#
#
#  arrayUnique = (arr = []) ->
#    retArr = []
#    hash = {}
#    
#    for item in arr
#      if ['number', 'string'].indexOf(typeof item) > -1
#        if hash[item] is undefined
#          retArr.push(item)
#          hash[item] = true
#      else
#        retArr.push(item)
#    
#    retArr
#
#  
#  watchers = () ->
#    for file in source
#      do (file)->
#        fs.watch(file, (evt, filename)->
#          setUp(->
#            execute(->
#              tearDown
#            )
#          )
#        )
#
#
#  prepareSource = (cb = (->)) ->
#    if Array.isArray(source)
#      source = source.map((f)->
#        path.join(appRoot, f)
#      )
#    
#    cb()
#
#
#  webRelativePath = (p) ->
#    index = 0
#    p = p.replace(appRoot, '')
#    splitted = p.split('/')
#
#    for section, idx in splitted
#      if section isnt '..' and topLevelDirs.indexOf(section) is -1
#        index = idx
#        break
#
#    webDirName+splitted.slice(index).join('/')
#
#
#  getFileNamesFromMap = (fileName) ->
#    {
#      inJs: fileName.replace('.map','.js')
#      outJs: fileName.replace('.map','.min.js')
#      inMap: fileName.replace('.map','.map')
#      outMap: fileName.replace('.map','.2.map')
#    }
#
#
#
#  functionPathToString = (loc, str) ->
#    loc = path.dirname(loc)
#    raw = str.substring(str.indexOf('(')+2, str.lastIndexOf(')')-1)
#    path.resolve(loc, raw)
#
#
#  requireize = (str) ->
#    """
#    do ->
#      module = module or {}
#      
#      str
#      
#      if module.exports then module.exports else {}
#    """
#
#
#
#  processRequires = (file = '', cb = (->))->
#    fs.readFile(file, {encoding: 'utf8'}, (err, parentData)->
#      errorMessage(err) if err
#      
##      if /require\((.+?)\)/gm.test(parentData)
##        requireds = arrayUnique(parentData.match(/require\((.+?)\)/gm))
##        paths = requireds.map((i)-> functionPathToString(file, i) )
##        
##        for reqPath, idx in paths when requireHash[reqPath] is undefined
##          tempReq = require(reqPath)
##          requireHash[reqPath] = require(reqPath).toString()
##      
##      
##      console.log(requireHash)
#      cb(parentData)
#    )
#
#  createJsAndMapFromCoffee = (file)->
#    (callback)->
#      processRequires(file, (data)->
#
#        commandToExec = "#{__dirname}/../node_modules/.bin/coffee -c -o #{cacheDir} -m #{file}"
#        webPathForOutput = webRelativePath(file.replace(appRoot, '').substring(1))
#        outputJsFile = cacheDir + path.basename(file).replace('.coffee', '.js')
#        movedJsFile = cacheDir + webPathForOutput.substring(1).replace(/[\/\\]/g, '-').replace('.coffee', '.js')
#        outputMapFile = outputJsFile.replace('.js', '.js.map')
#        movedMapFile = movedJsFile.replace('.js', '.map')
#
#        mainSourceFiles.push({path: webPathForOutput, content: data})
#        
#        exec(commandToExec, (err, stdout, stderr)->
#          errorMessage(err) if err
#
#          fs.rename(outputJsFile, movedJsFile, (err)->
#            errorMessage(err) if err
#
#            fs.rename(outputMapFile, movedMapFile, (err)->
#              errorMessage(err) if err
#
#              callback(null, {
#                origName: file
#                newName: movedMapFile
#              })
#            )
#          )
#        )
#      )
#
#
#
#  createUglyFiles = (item)->
#    (callback)->
#      fileName = getFileNamesFromMap(item.newName)
#
#      ugly = UglifyJS.minify(fileName.inJs, {
#        inSourceMap: fileName.inMap,
#        outSourceMap: fileName.outMap
#      })
# 
#      fs.writeFile(fileName.outJs, ugly.code, (err, out)->
#        errorMessage(err) if err
#
#        fs.writeFile(fileName.outMap, ugly.map.replace(/({"version":3,"file":")(.*?)(".)/gim, "$1"+path.basename(fileName.outJs)+"$3"), (err, out)->
#          callback(err, fileName)
#        )
#      )
#
#
#
#  joinFinalFiles = (results = [], cb = (->)) ->
#    cat(results.map((i)->
#      i.outMap
#    ), cacheDir + fileTime + '.js', cacheDir + fileTime + '.map')
#
#    fs.readFile(cacheDir + fileTime + '.js', {encoding: 'utf8'}, (err, data)->
#      errorMessage(err) if err
#
#      mainJSFile = data.replace(/(# sourceMappingURL=).*/gim, '$1' +webDirName+webFilePath.replace('.js', '.map'))
#
#      fs.writeFile(cacheDir + fileTime + '.js', mainJSFile, (err, data)->
#        errorMessage(err) if err
#
#        fs.readFile(cacheDir + fileTime + '.map', {encoding: 'utf8'}, (err, data)->
#          errorMessage(err) if err
#
#          modData = JSON.parse(data)
#          modData.sources = modData.sources.map((p)->
#            webRelativePath(p)
#          )
#          modData.file = webDirName+webFilePath
#
#          mainMapFile = JSON.stringify(modData)
#
#          fs.writeFile(cacheDir + fileTime + '.map', mainMapFile, (err, data)->
#            compiling = false
#            errorMessage(err) if err
#            
#            
#            cb()
#          )
#        )
#      )
#    )
#
#
#  execute = (cb = (->)) ->
#    if !compiling
#      compiling = true
#      if Array.isArray(source)
#        async.series(
#          source.map((file)->
#            createJsAndMapFromCoffee(file)
#          )
#
#          ,(err, results)->
#            errorMessage(err) if err
#
#            async.series(
#              results.map((item)->
#                createUglyFiles(item)
#              )
#
#              ,(err, results)->
#                errorMessage(err) if err
#                joinFinalFiles(results, cb)
#            )
#        )
#
#      else
#        cb()
#  
#  scanRootDirs(->
#    prepareSource(->
#      setUp(->
#        execute(->
#          tearDown(->
#            watchers()
#          )
#        )
#      )
#    )
#  )
#
#
#  (req, res, next)->
#    if req.method is 'GET'
#      if req.originalUrl is webDirName+webFilePath
#        res.set('Content-Type', 'text/javascript').send(mainJSFile)
#        next()
#        return
#    
#      if req.originalUrl is webDirName+webFilePath.replace('.js', '.map')
#        res.set('Content-Type', 'application/json').send(mainMapFile)      
#        next()
#        return
#    
#      index = -1
#      for file, idx in mainSourceFiles
#        if file.path is req.originalUrl
#          index = idx
#          break
#      
#      if index > -1
#        res.set('Content-Type', 'application/javascript').send(mainSourceFiles[index].content)
#        next()
#        return
#
#    next()