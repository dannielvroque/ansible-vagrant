# ansible-vagrantAqui está um README estruturado com base nos detalhes fornecidos:

```markdown
# Ansible - Lab de Automação

Este repositório contém a configuração e os playbooks necessários para realizar a automação de servidores usando **Ansible**. O laboratório é composto por três servidores: `control-node`, `app01` e `db01`. A automação envolve a instalação de pacotes, configuração de rede e deploy de uma aplicação REST simples.

## 🏗️ **Arquitetura do Lab**

### **Máquinas**
- **Control Node**: Onde o Ansible é instalado e executado para gerenciar os outros hosts.
- **Managed Hosts**:
  - **APP01**: Servidor onde a aplicação Java (REST API) será instalada e configurada.
  - **DB01**: Servidor MySQL onde o banco de dados será instalado e configurado.

### **Comunicação**
- O **Ansible** usa **SSH** para se comunicar com os **managed hosts**.
- **Nenhum software adicional precisa ser instalado nos managed hosts**, além do **Python** e **SSH**.

---

## 📂 **Estrutura de Diretórios**

A estrutura do repositório está organizada da seguinte forma:

```bash
ansible-lab/
│── control-node/                # Diretório do Control Node
│── app01/                        # Diretório do servidor app01
│── db01/                         # Diretório do servidor db01
│── playbooks/                    # Contém os playbooks para configurar os servidores
│── Vagrantfile                   # Arquivo para criar e configurar as VMs
│── README.md                     # Este arquivo de documentação
```

---

## 🔧 **Configuração do Control Node**

1. **Instalar o Ansible no Control Node**:

   - **Adicionar o repositório EPEL**:
     ```bash
     sudo yum install epel-release -y
     ```

   - **Instalar o Ansible**:
     ```bash
     sudo yum install ansible -y
     ```

   - **Configurar `/etc/hosts`** para adicionar os IPs dos servidores criados (app01, db01, etc.).

   - **Adicionar os hosts ao inventário do Ansible**:
     O arquivo de inventário será usado para listar todos os hosts que serão gerenciados pelo Ansible.

   - **Configuração SSH com autenticação por chave** (sem senha):
     - Gerar chave SSH:
       ```bash
       ssh-keygen
       ```

     - Copiar a chave para os servidores:
       ```bash
       ssh-copy-id user@host
       ```

2. **Testar a conectividade SSH com o comando**:
   ```bash
   ansible -m ping all
   ```

---

## 🔩 **Configuração dos Managed Hosts**

### **Vagrantfile para o Control Node**

```ruby
Vagrant.configure("2") do |config|
  config.vm.hostname = "control-node"
  config.vm.box = "centos/7"
  config.vm.network "private_network", ip: "192.168.1.2"
  config.vm.synced_folder ".", "/vagrant", type: "nfs"
end
```

### **Vagrantfile para o app01**

```ruby
Vagrant.configure("2") do |config|
  config.vm.hostname = "app01"
  config.vm.box = "centos/7"
  config.vm.network "private_network", ip: "192.168.1.3"
  config.vm.network "forwarded_port", guest: 8080, host: 8080
end
```

### **Vagrantfile para o db01**

```ruby
Vagrant.configure("2") do |config|
  config.vm.hostname = "db01"
  config.vm.box = "centos/7"
  config.vm.network "private_network", ip: "192.168.1.4"
  config.vm.network "forwarded_port", guest: 3306, host: 3306
end
```

---

## 🔨 **Playbooks do Ansible**

### **Playbook para o servidor app01**:

Este playbook realiza a instalação do Java, Maven e configura o ambiente para a aplicação.

```yaml
---
- name: Configuração do app01
  hosts: app01
  tasks:
    - name: Atualizar o sistema
      yum:
        name: '*'
        state: latest

    - name: Instalar o OpenJDK
      yum:
        name: java-1.8.0-openjdk
        state: present

    - name: Instalar o Maven
      yum:
        name: maven
        state: present

    - name: Adicionar o usuário APP
      user:
        name: app
        state: present

    - name: Clonar repositório Git da aplicação
      git:
        repo: 'https://github.com/dannielvroque/notes-app.git'
        dest: '/home/app/notes-app'
        version: 'master'

    - name: Configurar arquivo de propriedades
      template:
        src: 'application.properties.j2'
        dest: '/home/app/notes-app/application.properties'

    - name: Gerar pacote
      command: mvn clean package
      args:
        chdir: '/home/app/notes-app'

    - name: Configurar o serviço SystemD
      systemd:
        name: 'notes-app'
        state: started
        enabled: yes
```

### **Playbook para o servidor db01**:

Este playbook configura o MySQL e cria um banco de dados.

```yaml
---
- name: Configuração do db01
  hosts: db01
  tasks:
    - name: Atualizar o sistema
      yum:
        name: '*'
        state: latest

    - name: Instalar o MySQL
      yum:
        name: mysql-server
        state: present

    - name: Iniciar o serviço MySQL
      service:
        name: mysqld
        state: started
        enabled: yes

    - name: Criar banco de dados
      mysql_db:
        name: easy_notes
        state: present
```

---

## 📝 **Validando o Lab**

Após a execução do playbook, você pode validar a aplicação REST usando o **curl**.

### Inserir um novo registro:

```bash
curl -H "Content-Type: application/json" --data @note.json http://app01:8080/api/notes
```

### Recuperar todos os registros:

```bash
curl http://app01:8080/api/notes
```

### Apagar um registro:

```bash
curl -X DELETE -H "Content-Type: application/json" http://app01:8080/api/notes/1
```

---

## 🧑‍💻 **Requisitos**

### Control Node:
- **Python 2.7** ou superior.
- **Redhat, CentOS, Debian, macOS** ou outros sistemas baseados em BSD.
- **Windows** não é suportado.

### Managed Hosts:
- **SSH habilitado**.
- **Python 2.4 ou superior**.

---

## 🚀 **Como Rodar**

1. **Inicialize as VMs**:
   ```bash
   vagrant up
   ```

2. **Aplicar os Playbooks**:
   Execute o Ansible com os playbooks criados para configurar as VMs:
   ```bash
   ansible-playbook playbooks/app01.yml
   ansible-playbook playbooks/db01.yml
   ```

---

## 🛠️ **Referências**

- [Ansible Documentation](https://docs.ansible.com/)
- [Vagrant Documentation](https://www.vagrantup.com/docs)

---

## 📜 **Licença**

Este repositório está licenciado sob a licença **MIT**.

---

## 📚 **Referência ao Curso DevOps - Mão na Massa**

Se você está buscando aprender mais sobre DevOps de forma prática, recomendo o curso **[DevOps - Mão na Massa](https://www.udemy.com/course/devops-mao-na-massa/?srsltid=AfmBOorbohVQq4ub69jWrSUIu7adppeeUwsN8PD9R_uaQtGG-jeGIRql&couponCode=ST22MT240325G3)**, disponível na **Udemy**. Este curso oferece uma abordagem prática e completa sobre a implementação de práticas DevOps em ambientes reais.

🔗 **Acesse o curso aqui:** [DevOps - Mão na Massa](https://www.udemy.com/course/devops-mao-na-massa/?srsltid=AfmBOorbohVQq4ub69jWrSUIu7adppeeUwsN8PD9R_uaQtGG-jeGIRql&couponCode=ST22MT240325G3)

---