const cp= require('child_process');
cp.fork('./public/sub.js', ['subarg'], {
    silent: false,
    execArgv: [ '--max-old-space-size=3072', '--use-bundled-ca']
})