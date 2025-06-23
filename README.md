# **Infraestrutura no Azure com Monitoramento Avançado para SUSE e WebLogic**

Este repositório contém uma configuração de **Infraestrutura como Código (IaC)** utilizando **Terraform** para provisionar um ambiente seguro, escalável e monitorado no **Azure**. O projeto cria duas máquinas virtuais (VMs) – uma com **SUSE Linux Enterprise Server (SLES 15 SP5)** e outra com **Oracle WebLogic Server 12c** – em um ambiente de produção (`prod`) na região `eastus`. A infraestrutura inclui rede segmentada, segurança avançada, monitoramento detalhado, backup, e automação via CI/CD, alinhada com as melhores práticas do **Cloud Adoption Framework (CAF)** da Microsoft.

## **Resumo Executivo**

Este projeto demonstra uma solução robusta de IaC para um ambiente corporativo no Azure, com:
- **Segurança**: Credenciais no **Azure Key Vault**, discos criptografados, NSG restritivo, Private Endpoints, e Azure Firewall.
- **Monitoramento**: Métricas e logs via **Azure Monitor**, **Log Analytics**, e **Application Insights**, com dashboards e alertas para VMs e WebLogic (e.g., CPU, memória, heap JVM).
- **Resiliência**: Backup diário via **Azure Backup**, segmentação de rede, e sub-redes dedicadas.
- **Governança**: Política de tagging CAF e monitoramento de custos com **Azure Cost Management**.
- **Automação**: Configuração do WebLogic via **Custom Script Extension** e pipelines CI/CD para **Azure DevOps** e **GitHub Actions**.
- **Estado**: Gerenciado em **Azure Blob Storage** para colaboração segura.

Ideal para apresentações corporativas, o projeto é modular, reutilizável e otimizado para produção, com considerações de custo para uso em contas pessoais.

## **Visão Geral**

O código provisiona os seguintes recursos no Azure:
- **Grupo de Recursos**: `rg-suseweblogic-prod-eastus`.
- **Rede Virtual**:
  - VNet: `vnet-suseweblogic-prod-eastus` (espaço de endereço `10.0.0.0/16`).
  - Sub-redes: SUSE (`10.0.1.0/24`), WebLogic (`10.0.2.0/24`), Firewall (`10.0.3.0/24`), Private Endpoints (`10.0.4.0/24`).
  - NSG: Regras restritivas para SSH (porta 22, IPs confiáveis) e WebLogic (porta 7001, VNet interna).
  - Azure Firewall: Inspeção de tráfego.
  - Private Endpoints: Para Log Analytics e Azure Storage.
  - Network Watcher: Monitoramento de rede.
- **Máquinas Virtuais**:
  - **SUSE VM**: `vm-suse-prod-eastus`, SLES 15 SP5, `Standard_B1ms`.
  - **WebLogic VM**: `vm-weblogic-prod-eastus`, Oracle WebLogic 12c, `Standard_D2s_v3`.
- **Segurança**:
  - Azure Key Vault: Armazena credenciais.
  - Azure Disk Encryption: Criptografia de discos.
  - Política de Tagging CAF: Tags obrigatórias (`environment`, `project`, `owner`, `cost_center`).
- **Monitoramento e Diagnóstico**:
  - **Log Analytics Workspace**: `log-suseweblogic-prod-eastus`, SKU `PerGB2018`, retenção de 90 dias.
  - **Azure Monitor**: Métricas (`AllMetrics`, CPU, memória) e logs (`LinuxSyslog`, `LinuxSyslogEvents`).
  - **Application Insights**: Monitora WebLogic (JVM heap, sessões, tempo de resposta).
  - **Alertas**: Anomalias (15 minutos, `Sev2`) e personalizados (CPU > 80%, memória < 100 MB, heap JVM > 85%).
  - **Dashboards**: Visualizam CPU, tráfego de rede, heap JVM, e sessões do WebLogic.
  - **Consultas KQL**: Analisam erros e falhas de login do WebLogic.
- **Backup**: Azure Backup com política diária e retenção de 7 dias.
- **Estado do Terraform**: Armazenado em Azure Blob Storage (`tfsuseweblogicprod`).
- **Custos**: Monitoramento via Azure Cost Management com alertas de anomalias.
- **Automação**:
  - Configuração do WebLogic via Custom Script Extension.
  - Pipelines CI/CD em Azure DevOps e GitHub Actions.

## **Pré-requisitos**

- **Terraform**: Versão >= 1.0. Verifique com:
  ```bash
  terraform --version
  ```
- **Conta do Azure**: Service Principal ou login interativo com permissões de `Contributor` na assinatura e `Storage Blob Data Contributor` no storage account (após criação).
- **Azure CLI**: Para autenticação. Instale em [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) e faça login:
  ```bash
  az login
  ```
- **Variáveis**: Crie um arquivo `terraform.tfvars` com:
  ```hcl
  admin_username = "azureuser"
  trusted_ip     = "<SEU_IP_PÚBLICO>/32" # Ex.: "203.0.113.1/32"
  alert_email    = "admin@example.com"
  ```
  - Substitua `<SEU_IP_PÚBLICO>` pelo seu IP público (encontre em [whatismyipaddress.com](https://whatismyipaddress.com)).
- **Repositório**: Clone este repositório:
  ```bash
  git clone <URL do repositório>
  cd suse-weblogic-terraform
  ```

## **Arquitetura**

A infraestrutura é modular e segue práticas corporativas:
1. **Grupo de Recursos**: Centraliza recursos com tags CAF.
2. **Rede Virtual**: Segmentação, Azure Firewall, Private Endpoints, Network Watcher.
3. **Máquinas Virtuais**: SUSE para workloads gerais; WebLogic com configuração padrão.
4. **Segurança**: Key Vault, Disk Encryption, NSG restritivo.
5. **Monitoramento**: Log Analytics, Application Insights, dashboards, alertas, KQL.
6. **Resiliência**: Backup diário, estado em Blob Storage.
7. **Governança**: Tags CAF, monitoramento de custos.
8. **Automação**: Custom Script Extension, CI/CD.

## **Como Usar**

### **Primeira Execução**

Na primeira execução, o Azure Blob Storage (`tfsuseweblogicprod`) para o backend ainda não existe. Siga estes passos para criar os recursos e configurar o backend remoto:

1. **Navegue até o diretório do projeto**:
   ```bash
   cd suse-weblogic-terraform
   ```

2. **Inicialize o Terraform sem backend remoto**:
   ```bash
   terraform init -backend=false
   ```

3. **Valide o código**:
   ```bash
   terraform validate
   ```

4. **Planeje a infraestrutura**:
   ```bash
   terraform plan -var-file="terraform.tfvars" -out=suseweblogic.plan
   ```

5. **Aplique a infraestrutura**:
   ```bash
   terraform apply suseweblogic.plan
   ```
   - Confirme com `yes`.

6. **Configure o backend remoto**:
   ```bash
   terraform init -reconfigure
   ```
   - Confirme a migração do estado local para o backend remoto com `yes`.

7. **Verifique o estado**:
   ```bash
   terraform state list
   ```

### **Execuções Subsequentes**

Com o backend remoto configurado, siga estes passos:

1. **Navegue até o diretório do projeto**:
   ```bash
   cd suse-weblogic-terraform
   ```

2. **Inicialize o Terraform**:
   ```bash
   terraform init
   ```

3. **Valide o código**:
   ```bash
   terraform validate
   ```

4. **Planeje as alterações**:
   ```bash
   terraform plan -var-file="terraform.tfvars" -out=suseweblogic.plan
   ```

5. **Aplique as alterações**:
   ```bash
   terraform apply suseweblogic.plan
   ```
   - Confirme com `yes`.

### **Destruindo a Infraestrutura**

Para evitar custos, destrua todos os recursos após os testes:

1. **Destruir os recursos**:
   ```bash
   terraform destroy -var-file="terraform.tfvars"
   ```
   - Confirme com `yes`.

2. **Verifique no portal Azure**:
   - Confirme que o grupo de recursos `rg-suseweblogic-prod-eastus` foi excluído:
     ```bash
     az group show --name rg-suseweblogic-prod-eastus
     ```
   - Acesse `Cost Management > Cost Analysis` para confirmar zero custos.

3. **Limpe o estado do backend (opcional)**:
   - Exclua o arquivo `prod.terraform.tfstate` no container `tfstate`:
     ```bash
     az storage blob delete --account-name tfsuseweblogicprod --container-name tfstate --name prod.terraform.tfstate
     ```

## **Custos**

Este projeto é projetado para ambientes corporativos, mas pode ser usado em contas pessoais com cuidado para evitar custos elevados. Abaixo, estimativas de custos e estratégias para minimizá-los, especialmente para testes curtos.

### **Estimativa de Custos (4 Horas de Teste)**

- **Máquinas Virtuais**:
  - SUSE (`Standard_B1ms`): ~$0.013/hora, ~$0.052 por 4 horas.
  - WebLogic (`Standard_D2s_v3`): ~$0.096/hora, ~$0.384 por 4 horas.
- **Azure Firewall**: ~$1.25/hora, ~$5 por 4 horas (principal fonte de custo).
- **Log Analytics**: ~$2.30/GB/mês, ~$0.05–$0.20 por 4 horas (<1 GB).
- **Azure Backup**: ~$0.0225/GB, ~$0.05 para discos de 30 GB.
- **Outros (Key Vault, Blob Storage, Public IPs, Application Insights)**: ~$0.10.
- **Total**: ~$5.64–$5.84 para 4 horas com Firewall; ~$0.64–$0.84 sem Firewall.

### **Mitigação de Custos**

- **Remova o Azure Firewall**: Para contas pessoais, edite `modules/network/main-network.tf` e remova:
  ```hcl
  resource "azurerm_firewall" "firewall" { ... }
  resource "azurerm_public_ip" "firewall_pip" { ... }
  resource "azurerm_subnet" "firewall_subnet" { ... }
  ```
  Ajuste `modules/network/variables-network.tf`:
  ```hcl
  default = {
    suse      = ["10.0.1.0/24"]
    weblogic  = ["10.0.2.0/24"]
    endpoints = ["10.0.4.0/24"]
  }
  ```
- **Limite o Tempo de Teste**: Execute testes em 2–4 horas e destrua imediatamente com `terraform destroy`.
- **Reduza Retenção de Logs**: Em `main.tf`, ajuste `retention_in_days` do Log Analytics para 30 dias:
  ```hcl
  retention_in_days = 30
  ```
- **Monitore Tráfego de Saída**: Evite downloads grandes para minimizar custos (~$0.087/GB após 5 GB gratuitos).

### **Garantindo Zero Custos Após `terraform destroy`**

- O `terraform destroy` remove todos os recursos gerenciados, incluindo:
  - Grupo de recursos `rg-suseweblogic-prod-eastus`.
  - VMs, discos, IPs públicos, Key Vault, Blob Storage, Log Analytics, Backup, Firewall.
- **Verificação**:
  - Confirme no portal Azure que o grupo de recursos não existe.
  - Acesse `Cost Management > Cost Analysis` para verificar zero custos.
  - Exclua manualmente o arquivo `prod.terraform.tfstate` no container `tfstate` (se necessário).
- **Atenção**: Recursos criados fora do Terraform (e.g., manualmente) não serão destruídos. Use uma assinatura dedicada para evitar custos residuais.

## **Estrutura do Projeto**

- `main.tf`: Recursos principais (VMs, Key Vault, Backup, Application Insights, etc.).
- `provider.tf`: Provedor Azure e backend Blob Storage.
- `variables.tf`: Variáveis (`admin_username`, `trusted_ip`, `alert_email`).
- `policy.tf`: Política de tagging CAF.
- `kql-queries.tf`: Consultas KQL para WebLogic.
- `terraform.tfvars`: Valores das variáveis.
- `modules/`:
  - `vm/`: VMs SUSE e WebLogic (v1.0.0).
  - `network/`: VNet, sub-redes, NSG, Firewall, Private Endpoints (v1.0.0).
  - `monitor/`: Monitoramento, alertas, diagnostic settings (v1.0.0).
  - `dashboard/`: Dashboards personalizados (v1.0.0).
- `ci-cd/`:
  - `azure-devops/`: Pipeline Azure DevOps.
  - `github-actions/`: Workflow GitHub Actions.

## **Itens Monitorados**

- **VMs**:
  - Uso de CPU (%).
  - Memória disponível (bytes).
  - Tráfego de rede (entrada/saída).
  - Logs do sistema (`LinuxSyslog`, `LinuxSyslogEvents`).
- **WebLogic**:
  - Uso de heap JVM (%).
  - Sessões ativas.
  - Tempo de resposta (via Application Insights).
  - Erros e falhas de login (via KQL).
- **Rede**:
  - Tráfego via Network Watcher.
  - Segurança via Firewall.

**Dashboards**: Gráficos de CPU, tráfego de rede, heap JVM, sessões do WebLogic.  
**Alertas**: Anomalias (15 minutos, `Sev2`), CPU > 80%, memória < 100 MB, heap JVM > 85%.

## **Acesso à Rede**

- **SUSE VM**: SSH (porta 22) restrito ao `trusted_ip`.
- **WebLogic VM**: SSH (porta 22, `trusted_ip`), console WebLogic (porta 7001, VNet interna).
- **Segurança**: NSG, Azure Firewall, Private Endpoints.

## **Recomendações para Expansão**

- **Alta Disponibilidade**: Adicione Availability Sets ou VM Scale Sets.
- **Segurança**: Integre Azure Active Directory ou use Azure Bastion.
- **Monitoramento**: Inclua métricas de disco e JDBC no WebLogic.
- **Automação**: Expanda Custom Script Extension ou use Terratest.

## **Conclusão**

Este projeto oferece uma solução robusta de IaC para provisionar e monitorar VMs SUSE e WebLogic no Azure, com segurança, resiliência, e governança. Alinhado com o CAF, é ideal para ambientes corporativos e demonstra práticas modernas de DevOps. Para contas pessoais, remova o Firewall e limite os testes para minimizar custos. Contate a equipe de infraestrutura (`it-team`, cost center: `12345`) para dúvidas.