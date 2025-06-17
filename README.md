
# **Infraestrutura no Azure com Monitoramento e Diagnóstico para Máquinas Virtuais (VM)**

Este repositório contém uma configuração de **Infraestrutura como Código (IaC)** utilizando **Terraform** para provisionar recursos no **Azure**. A configuração inclui a criação de um **grupo de recursos**, **rede virtual**, **máquina virtual (VM)** e configura o **monitoramento** e **diagnóstico** utilizando **Azure Monitor** e **VM Insights**.

## **Visão Geral**

O código cria os seguintes recursos no Azure:
- **Grupo de Recursos (Resource Group)**: Para agrupar todos os recursos.
- **Rede Virtual (Virtual Network)**: Para fornecer conectividade entre os recursos.
- **Máquina Virtual (VM)**: Provisionamento de uma VM dentro da rede virtual.
- **Monitoramento e Diagnóstico**:
  - Configuração de **Diagnostic Settings** para capturar métricas e logs da VM.
  - Configuração do **VM Insights** para coletar dados detalhados sobre o desempenho da máquina virtual.
  - Armazenamento dos dados de monitoramento em um **Log Analytics Workspace**.

## **Pré-requisitos**

Antes de usar o código, certifique-se de que você tem o seguinte configurado:
- **Terraform**: A versão recomendada é a 1.x. Você pode verificar se o Terraform está instalado e qual versão está em uso com o comando:
  ```bash
  terraform --version
  ```
- **Conta do Azure**: Você deve ter uma conta no Azure e um **Service Principal** com permissões adequadas para criar os recursos no Azure.
- **Azure CLI**: Embora não seja estritamente necessário, é recomendável ter o Azure CLI instalado para autenticar o Terraform com o Azure. Você pode instalar o Azure CLI [aqui](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

## **Arquitetura**

O código configura os seguintes recursos na plataforma **Azure**:
1. **Grupo de Recursos**: Um container lógico para agrupar os recursos.
2. **Rede Virtual**: Para permitir a comunicação entre os recursos.
3. **Máquina Virtual (VM)**: Uma VM provisionada para rodar aplicações ou outros serviços.
4. **Monitoramento e Diagnóstico**:
   - **Azure Monitor**: Para coletar métricas e logs.
   - **Log Analytics Workspace**: Para armazenar e consultar os dados coletados.
   - **VM Insights**: Para monitoramento detalhado da saúde e desempenho da VM.

Além disso, o código configura o diagnóstico da VM e a coleta de métricas e logs, facilitando o gerenciamento e análise de dados da máquina virtual.

## **Como Usar**

### 1. **Configuração Inicial**

Clone o repositório:
```bash
git clone <URL do repositório>
cd <diretório do repositório>
```

### 2. **Configuração do Terraform**

Antes de rodar o Terraform, configure as variáveis necessárias no arquivo `terraform.tfvars`.

Exemplo do arquivo `terraform.tfvars`:
```hcl
resource_group_name = "rg-suse-vm"
location            = "BrazilSouth"
admin_username      = "azureuser"
admin_password      = "Password123!"
```

### 3. **Inicializando o Terraform**

Primeiro, execute o comando `terraform init` para inicializar o ambiente Terraform, baixar os provedores e preparar o plano de execução:
```bash
terraform init
```

### 4. **Validando a Configuração**

Para validar se a configuração está correta, use o comando `terraform validate`:
```bash
terraform validate
```

### 5. **Aplicando a Infraestrutura**

Após validar, você pode aplicar a infraestrutura:
```bash
terraform apply -var-file="terraform.tfvars"
```

Isso vai criar os recursos no Azure conforme definido no código. O Terraform irá pedir confirmação antes de aplicar as mudanças, basta digitar `yes` quando solicitado.

### 6. **Monitoramento e Diagnóstico**

O código configura o monitoramento da máquina virtual através do **Azure Monitor**. Ele habilita a coleta de métricas e logs da VM, incluindo:
- **Logs de sistema** e **logs de aplicação**.
- **Métricas de uso de CPU**, **memória**, **disco** e **rede**.
- **Alertas** podem ser configurados no **Log Analytics Workspace** para notificar sobre possíveis problemas.

Você pode acessar os logs e as métricas coletadas através do **Log Analytics** no portal do Azure.

### 7. **Destruindo a Infraestrutura**

Se você quiser destruir todos os recursos criados, basta rodar o comando:
```bash
terraform destroy -var-file="terraform.tfvars"
```

Isso removerá todos os recursos criados no Azure.

## **Estrutura do Projeto**

- `main.tf`: Contém a definição dos recursos principais (grupo de recursos, rede, VM e monitoramento).
- `variables.tf`: Define as variáveis utilizadas no código.
- `outputs.tf`: Define as saídas que serão retornadas após a criação dos recursos, como o IP público da VM.
- `terraform.tfvars`: Arquivo para definir os valores das variáveis, como o nome do grupo de recursos, localização, usuário administrador da VM, entre outros.
- `modules/`: Contém os módulos reutilizáveis para a configuração da rede e da máquina virtual.

## **Itens Monitorados**

Com essa configuração, você será capaz de monitorar os seguintes itens da sua máquina virtual (VM) no Azure:
- **Uso de CPU**
- **Uso de Memória**
- **Uso de Disco**
- **Uso de Rede**
- **Logs de sistema operacional** e **aplicações**
- **Alertas de saúde** e desempenho

Você pode configurar alertas no **Azure Monitor** para receber notificações quando algum valor de métrica ultrapassar um limite definido, como:
- Alta utilização de CPU.
- Queda no desempenho de disco.
- Problemas de conectividade de rede.

## **Conclusão**

Este repositório fornece uma configuração completa de infraestrutura como código para provisionar e monitorar máquinas virtuais no Azure. Usando o **Terraform** e **Azure Monitor**, você pode automatizar a criação da infraestrutura e garantir que a máquina virtual esteja sendo monitorada constantemente.
