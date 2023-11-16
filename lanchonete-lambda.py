import pymysql
import jwt
import os
import base64
import datetime

def lambda_handler(event, context):
    cpf = event.get("cpf")
    conn = pymysql.connect(
        host=os.environ['DB_HOST'],
        user=os.environ['DB_USER'],
        password=os.environ['DB_PASSWORD'],
        database=os.environ['DB_NAME'],
        connect_timeout=5
    )
    cursor = conn.cursor()

    try:
        cursor.execute("SELECT nome FROM clientes WHERE cpf = %s", (cpf,))
        result = cursor.fetchone()

        if result:
            name = result[0]
            jwt_token = generate_jwt(cpf, name)
            return {
                'statusCode': 200,
                'body': jwt_token
            }
        else:
            return {
                'statusCode': 404,
                'body': 'CPF não encontrado'
            }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': str(e)
        }
    finally:
        # Fechar a conexão com o banco de dados
        conn.close()

def generate_jwt(cpf, name):
    secret_key = os.environ['SECRET']
    secret = base64.b64decode(secret_key)

    payload = {
        "sub": cpf,
        "name": name,
        "iat": int(datetime.datetime.utcnow().timestamp())
    }

    jwt_token = jwt.encode(payload, secret, algorithm='HS256')
    return jwt_token
