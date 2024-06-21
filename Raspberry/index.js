const express = require('express');
const app = express();
const ftp = require("basic-ftp");
const fs = require('fs');
const path = require('path');


// Cria um diretório chamado 'temp' na pasta atual
let dir = path.join(__dirname, 'temp');

// Verifica se o diretório existe, se não, cria o diretório
if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir);
}

app.use(express.json());

app.post('/enviar', async (req, res) => {
    const { ip, impressao, chave } = req.body;

    const client = new ftp.Client();
    client.ftp.verbose = true;
    console.log(ip)
    console.log(impressao)
    console.log(chave)
    try {
        await client.access({
            host: ip,
            user: "admin",
            password: "1234"
        });
        // Obtém a data e hora atual
        let data = new Date();

        // Formata a data e hora no formato 'ano-mes-dia-hora-minuto-segundo'
        let nomeArquivo = data.getFullYear() + '-' + (data.getMonth() + 1) + '-' + data.getDate() + '-' + data.getHours() + '-' + data.getMinutes() + '-' + data.getSeconds() + '.txt';

        // Define o caminho do arquivo
        let arquivo = path.join(dir, nomeArquivo);

        // Escreve o conteúdo no arquivo
        /*
       await  fs.writeFile(arquivo, impressao, (err) => {
            if (err) throw err;
            console.log('O conteúdo foi salvo em', arquivo);
        });
        */
        try {
            fs.writeFileSync(arquivo, impressao);
            console.log('O conteúdo foi salvo em', arquivo);
        } catch (err) {
            throw err;
        }

       await client.uploadFrom(arquivo, "print_"+data.getSeconds()+".prn");
    }
    catch (err) {
        console.log(err);
    }
    client.close();

    res.send('Arquivo enviado com sucesso!');
});

app.listen(3001, () => {
    console.log('Servidor rodando na porta 3001');
});
