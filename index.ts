import * as AWS from 'aws-sdk';
import { Context }  from 'aws-lambda';
import * as Knex from 'knex';
AWS.config.update({ region: 'us-east-1' });
import jwt from 'jsonwebtoken';

const host = process.env.DB_HOST;
const user = process.env.DB_USER;
const password = process.env.DB_PASSWORD;
const database = process.env.DB_DATABASE;
const secret = process.env.SECRET;

const connection = {
    ssl: {rejectUnauthorized: false},
    host,
    user,
    password,
    database,
};

const knex = Knex({
    client: 'mysql',
    connection,
});
let count = 0;
export const handler = async function (event: any, context: Context) {
    const { cpf } = JSON.parse(event.body);
    try {
        const res = await knex('costumer').select('cpf').where({ cpf });
        if (res.length > 0) {
            const token = jwt.sign({ cpf }, secret, { expiresIn: '1h' });
            return { statusCode: 200, body: JSON.stringify({ token }) };
        } else {
            return { statusCode: 404, body: JSON.stringify({ message: 'CPF não encontrado' }) };
        }
    } catch (err) {
        console.log(err);
        return { statusCode: 500, body: JSON.stringify({ message: 'Erro interno' }) };
    }
};
