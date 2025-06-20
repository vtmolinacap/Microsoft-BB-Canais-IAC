# **Infraestrutura no Azure com Monitoramento e Diagnóstico para Máquinas Virtuais (SUSE e WebLogic)**

Este repositório contém uma configuração de **Infraestrutura como Código (IaC)** utilizando **Terraform** para provisionar recursos no **Azure**. A configuração cria um ambiente com duas máquinas virtuais (uma SUSE Linux e outra com Oracle WebLogic Server), uma rede virtual com acesso público, e monitoramento avançado utilizando **Azure Monitor**, **Log Analytics Workspace**, e **dashboards personalizados** para visualização de métricas.

## **Visão Geral**

O código provisiona os seguintes recursos no Azure:
- **Grupo de Recursos**: Um container lógico para todos os recursos, nomeado como `rg-suseweblogic-prod-eastus`.
- **Rede Virtual**: Inclui uma VNet, sub-rede, IPs públicos, e um Network Security Group (NSG) com regras para SSH (porta 22) e WebLogic (porta 7001).
- **Máquinas Virtuais (VMs)**:
  - Uma VM baseada em SUSE Linux Enterprise Server (SLES 15 SP5).
  - Uma VM com Oracle WebLogic Server.
- **Monitoramento e Diagnóstico**:
  - **Azure Monitor Diagnostic Settings**: Coleta métricas e logs (ex.: LinuxSyslog, LinuxSyslogEvents) para ambas as VMs.
  - **Log Analytics Workspace**: Armazena logs e métricas com retenção de 7 dias.
  - **Alertas Inteligentes**: Configurados para detectar anomalias com notificação por e-mail.
  - **Dashboards**: Visualização de métricas de CPU e tráfego de rede para cada VM.

## **Pré-requisitos**

Antes de usar o código, certifique-se de que possui:
- **Terraform**: Versão 1.x ou superior. Verifique com:
  ```bash
  terraform --version
  ```
- **Conta do Azure**: Um **Service Principal** com permissões para criar recursos no Azure (ex.: Contributor role).
- **Azure CLI**: Recomendado para autenticação. Instale em [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
- **Variáveis sensíveis**: Configure a senha do administrador da VM de forma segura (ex.: via variáveis de ambiente ou Azure Key Vault).

## **Arquitetura**

A infraestrutura é organizada em módulos reutilizáveis:
1. **Grupo de Recursos**: `rg-suseweblogic-prod-eastus`, contendo todos os recursos.
2. **Rede Virtual**:
   - VNet: `vnet-suseweblogic-prod-eastus` com espaço de endereço `10.0.0.0/16`.
   - Sub-rede: `subnet-suseweblogic-prod-eastus` com endereço `10.0.1.0/24`.
   - IPs Públicos: Um para cada VM (`pip-suse-prod-eastus`, `pip-weblogic-prod-eastus`).
   - NSG: `nsg-suseweblogic-prod-eastus` com regras para SSH e WebLogic.
3. **Máquinas Virtuais**:
   - **SUSE VM**: `vm-suse-prod-eastus`, com SLES 15 SP5, tamanho `Standard_B1ms`.
   - **WebLogic VM**: `vm-weblogic-prod-eastus`, com Oracle WebLogic Server, tamanho `Standard_D2s_v3`.
4. **Monitoramento**:
   - **Log Analytics Workspace**: `log-suseweblogic-prod-eastus` com SKU `PerGB2018` e retenção de 30 dias.
   - **Diagnostic Settings**: Coleta métricas (`AllMetrics`) e logs (`LinuxSyslog`, `LinuxSyslogEvents`) para ambas as VMs.
   - **Alertas**: Regras de detecção de anomalias com frequência de 5 minutos e severidade `Sev2`.
   - **Dashboards**: Um por VM, exibindo métricas de CPU e tráfego de rede.

## **Como Usar**

### 1. **Configuração Inicial**

Clone o repositório:
```bash
git clone <URL do repositório>
cd <diretório do repositório>
```

### 2. **Configuração do Terraform**

Crie um arquivo `terraform.tfvars` para definir as variáveis necessárias. Exemplo:

```hcl
admin_username = "azureuser"
admin_password = "SuaSenhaSegura123!"
alert_email    = "admin@example.com"
```

**Nota**: Evite armazenar senhas em arquivos versionados. Considere usar variáveis de ambiente ou Azure Key Vault para maior segurança.

### 3. **Inicializando o Terraform**

Execute o comando para baixar os provedores e módulos:
```bash
terraform init
```

### 4. **Validando a Configuração**

Valide a sintaxe do código:
```bash
terraform validate
```

### 5. **Planejando a Infraestrutura**

Gere um plano de implantação e salve-o para revisão:
```bash
terraform plan -var-file="terraform.tfvars" -out=suseweblogic.plan
```

Revise o plano com:
```bash
terraform show suseweblogic.plan
```

### 6. **Aplicando a Infraestrutura**

Aplique o plano salvo:
```bash
terraform apply suseweblogic.plan
```

Confirme digitando `yes` quando solicitado. Isso criará todos os recursos no Azure.

### 7. **Monitoramento e Diagnóstico**

Os recursos de monitoramento estão configurados para:
- **Coletar métricas e logs**: Acesse o **Log Analytics Workspace** no portal do Azure para consultar logs e métricas.
- **Visualizar métricas**: Dashboards no Azure Portal mostram o uso de CPU e tráfego de rede para cada VM.
- **Receber alertas**: Notificações por e-mail são enviadas para anomalias detectadas (ex.: falhas na VM).

### 8. **Destruindo a Infraestrutura**

Para remover todos os recursos:
```bash
terraform destroy -var-file="terraform.tfvars"
```

Confirme com `yes` para excluir os recursos.

## **Estrutura do Projeto**

- `main.tf`: Define o grupo de recursos, Log Analytics Workspace, e chama os módulos para VMs, rede, monitoramento e dashboards.
- `variables.tf`: Declara variáveis como `admin_username`, `admin_password`, e `alert_email`.
- `outputs.tf`: Retorna saídas como os IDs das VMs (`suse_vm_id`, `weblogic_vm_id`).
- `terraform.tfvars`: Define valores para as variáveis (ex.: nome do grupo de recursos, localização).
- `modules/`:
  - `vm/`: Módulo reutilizável para criar VMs (SUSE e WebLogic).
  - `network/`: Configura VNet, sub-rede, IPs públicos, e NSG.
  - `monitor/`: Configura diagnostic settings, alertas, e grupos de ação.
  - `dashboard/`: Cria dashboards personalizados para cada VM.

## **Itens Monitorados**

As VMs são monitoradas para:
- **Uso de CPU**: Percentual de utilização.
- **Tráfego de Rede**: Entrada e saída de dados.
- **Logs do Sistema**: Inclui `LinuxSyslog` e `LinuxSyslogEvents`.
- **Anomalias**: Alertas baseados no detector `FailureAnomaliesDetector`.

Os dashboards exibem:
- Gráfico de linha para uso de CPU.
- Gráfico de linha para tráfego de rede (entrada e saída).

Alertas são enviados por e-mail quando anomalias são detectadas, com severidade `Sev2` e verificação a cada 5 minutos.

## **Acesso à Rede**

- **SUSE VM**: Acessível via SSH (porta 22) com IP público.
- **WebLogic VM**: Acessível via SSH (porta 22) e console WebLogic (porta 7001) com IP público.
- **Segurança**: O NSG restringe o tráfego de entrada às portas 22 (SSH) e 7001 (WebLogic).

## **Recomendações**

- **Segurança**:
  - Substitua senhas hardcoded por integração com **Azure Key Vault**.
  - Considere usar chaves SSH em vez de autenticação por senha.
- **Alta Disponibilidade**:
  - Adicione um **Load Balancer** para o WebLogic em cenários de produção.
  - Use **Availability Sets** ou **VM Scale Sets** para redundância.
- **Monitoramento Avançado**:
  - Configure alertas adicionais para memória e disco.
  - Integre com ferramentas de terceiros (ex.: Grafana) para visualização avançada.
- **Automação**:
  - Integre com pipelines CI/CD para implantações automatizadas.
  - Use provisioners para configurar o WebLogic Server pós-implantação.

## **Conclusão**

Este repositório fornece uma solução completa de IaC para provisionar e monitorar duas VMs (SUSE e WebLogic) no Azure, com rede pública segura e monitoramento avançado. O uso de módulos reutilizáveis facilita a escalabilidade e manutenção. Para mais detalhes, consulte os arquivos Terraform ou entre em contato com a equipe de infraestrutura.
