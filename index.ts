import * as AWS from 'aws-sdk';
import { Context }  from 'aws-lambda';
import * as Knex from 'knex';
AWS.config.update({ region: 'us-east-1' });


const host = '10fecc69c7aa'
const user = 'usuario'
const password = 'q1w2e3r4'
const database = 'lanchonete'

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
  try{
      const res = await knex({a: 'costumer'}).select({cpf: "a.cpf"}).whereRaw(event)
  }catch(err){
      console.log(err);
  }
};

