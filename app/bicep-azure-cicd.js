const http = require('http');

const server = http.createServer(function(req, res) {

    if (req.method === 'GET' && req.url === '/') { // ici on veut récup. des infos, donc on travaille sur la réponse 'GET' du serveur
        res.writeHead(200, {'Content-Type' : 'text/plain'}); // on prévient le navigateur du format de la réponse (en loccurence on aura du texte)
        res.end('[PAGE D\'ACCUEIL] Bienvenue sur l\'application node.js hébergée sur Azure Web App'); // on envoie la réponse
    }

    else if (req.method === 'GET' && req.url === '/status') { // si le endpoint est '/status', on renvoi au client la date exacte (heure, etc...) de la requête et 
        const response_1 = {                                   // le status de celle ci
            status: 'ok',
            time: new Date().toISOString()
        };
        res.writeHead(200, {'Content-Type': 'application/json'});
        res.end(JSON.stringify(response_1));
    }
    
    else if (req.method === 'GET' && req.url === '/info') {
        const response_2 = { // process.env.[nom_de_la_variable] selon la doc. d'Azure
            app_name: process.env.WEBSITE_SITE_NAME || 'bicep-demo-webapp', // on récup la valeur, OU on prends un nom par défaut si la première query marche pas
            os: process.platform, // "linux" sur Azure Web App Linux
            node_version: process.version, // la version de Node.js
            region: process.env.REGION_NAME || 'westeurope',
            env: process.env.NODE_ENV || 'production' // variable d'environnement
        };
        res.writeHead(200, {'Content-Type': 'application/json'});
        res.end(JSON.stringify(response_2));
    }

    else {
        res.writeHead(404, {'Content-Type': 'application/json'});
        res.end(JSON.stringify({error: 'Not Found'}));
    }

}).listen(3000, function() {
    console.log(`L\'app est en écoute sur le port 3000`)
});