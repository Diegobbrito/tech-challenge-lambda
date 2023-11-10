const mysql = require('mysql');
const jwt = require('jsonwebtoken');

const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
});

const secret = process.env.SECRET

exports.handler = async (event) => {
    const cpf = event.queryStringParameters.cpf;

    return new Promise((resolve, reject) => {
        pool.query('SELECT * FROM tabela WHERE cpf = ?', [cpf], (error, results) => {
            if (error) {
                reject(error);
            } else {
                if (results.length > 0) {
                    const token = jwt.sign({ cpf }, secret, { expiresIn: '1h' });
                    resolve({
                        statusCode: 200,
                        body: JSON.stringify({ token }),
                    });
                } else {
                    resolve({
                        statusCode: 404,
                        body: JSON.stringify({ message: 'CPF não encontrado' }),
                    });
                }
            }
        });
    });
};
