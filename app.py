from flask import Flask, render_template, request, jsonify
import docker
import requests
import datetime
import os

app = Flask(__name__)
client = docker.from_env()

def validate_turnstile(token, secret, remoteip=None):
  url = 'https://challenges.cloudflare.com/turnstile/v0/siteverify'

  data = {
    'secret': secret,
    'response': token
  }

  if remoteip:
    data['remoteip'] = remoteip

  try:
    response = requests.post(url, data=data, timeout=10)
    response.raise_for_status()
    return response.json()
  except requests.RequestException as e:
    print(f"Turnstile validation error: {e}")
    return {'success': False, 'error-codes': ['internal-error']}

@app.route('/restart', methods=['GET', 'POST'])
def restart_container_post():
  if request.form.get('password') != os.environ['ACCESS_CODE']: return jsonify({'status': 'error', 'description': 'Access code is invalid'})
  token = request.form.get('cf-turnstile-response')
  remoteip = request.headers.get('CF-Connecting-IP') or \
              request.headers.get('X-Forwarded-For') or \
              request.remote_addr

  validation = validate_turnstile(token, os.environ['TURNSTILE_SECRET'], remoteip)

  if validation['success']:
    print(f'[{datetime.datetime.now(datetime.timezone.utc)} UTC+0] Turnstile validation success! Remote IP: {remoteip}. Restarting the container')
    print(client.containers.get('tor').restart())
    return jsonify({'status': 'success', 'message': 'Container restarted successfully'})
  else:
    print(f'[{datetime.datetime.now(datetime.timezone.utc)} UTC+0] Turnstile validation failed! Remote IP: {remoteip}. Errors: {validation['error-codes']}')
    return jsonify({
        'status': 'error',
        'message': 'Verification failed',
        'errors': validation['error-codes']
    }), 400

if __name__ == '__main__':
  app.run(host='0.0.0.0')
