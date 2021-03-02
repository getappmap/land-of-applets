import sys
import os
import paramiko
import select

class Demo:
    def runDemo(self):
        username = 'test'
        password = 'test'
        command = 'hostname'
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            ssh.connect("localhost", 22, username, password)
        except Exception as e:
            print("Unable to SSH: %s" % e)
            sys.exit()
        stdin, stdout, stderr = ssh.exec_command(command)
        for line in stdout:
            print("Hostname: %s" % line)
        ssh.close()
        return