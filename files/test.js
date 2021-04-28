fs = require('fs');

tmpfile = '/tmp/nodejstest';

fs.writeFile(tmpfile, 'this is test data', function (err, data) {
    if (err) {
        console.error(err);
        process.exit(1);
        return;
    }

    console.log('Wrote test file successfully');
    
    // Delete file
    try {
        fs.unlinkSync(tmpfile)
    } catch (err) {
        console.error(err);
        process.exit(1);
        return;
    }
 
    console.log('Removed test file successfully');
});

