# SakuraOS 🌸

O **SakuraOS** é um projeto de customização (rice) do Arch Linux, desenhado para emular o visual e usabilidade do **macOS** combinados com a estética de **Anime**. 

Este repositório fornece todas as ferramentas necessárias para você construir sua própria distribuição customizada inicializável (ISO) ou transformar qualquer instalação limpa do Arch Linux no visual final do SakuraOS.

---

## 📸 Wallpaper Padrão

O papel de parede oficial do SakuraOS está localizado em: `assets/anime_wallpaper.jpg`. É uma composição moderna minimalista inspirada nas flores de cerejeira (sakura) com elementos urbanos ao pôr do sol, desenhado para se misturar harmoniosamente com temas escuros e transparências (blur).

---

## 📁 Estrutura do Repositório

- `.github/workflows/build.yml` : Workflow do GitHub Actions para compilar a ISO automaticamente na nuvem.
- `archiso/` : Arquivos de definição e arquivos a serem adicionados na ISO final.
  - `profiledef.sh` : Definições básicas da distro (nome, versão, etc.).
  - `packages.x86_64` : Lista de pacotes que serão pré-instalados na ISO.
  - `airootfs/` : Estrutura de arquivos que serão copiados diretamente para o sistema live.
- `assets/` : Recursos de mídia e imagens da distro.
- `build-iso.sh` : Script para compilar a ISO localmente (caso você esteja em um sistema Linux).
- `build-docker.sh` : Script para compilar a ISO usando Docker (funciona no macOS).
- `setup-sakura.sh` : Script de configuração pós-instalação para aplicar o visual em qualquer sistema rodando Arch Linux.

---

## 🚀 Como Compilar a ISO na Nuvem (Ideal para macOS)

Como compilar uma ISO de Linux requer o kernel Linux e ferramentas de loopback, a forma mais fácil de fazer isso se você está no macOS é usar o **GitHub Actions**:

1. Crie um repositório no seu GitHub.
2. Inicialize o repositório local e envie os arquivos deste projeto para o GitHub:
   ```bash
   git init
   git remote add origin https://github.com/SEU_USUARIO/SAKURA_OS.git
   git add .
   git commit -m "Initial commit of SakuraOS configs"
   git branch -M main
   git push -u origin main
   ```
3. Acesse a aba **Actions** no seu repositório do GitHub.
4. Você verá o workflow **Build SakuraOS ISO** rodando. Assim que finalizar (cerca de 5 a 10 minutos), você poderá baixar a ISO compilada diretamente nos artefatos da execução!

### 🐳 Alternativa: Compilar Localmente via Docker (no Mac)

Se você tem o **Docker Desktop** instalado no seu Mac, pode compilar a ISO localmente sem precisar do GitHub:

1. Certifique-se de que o Docker está aberto e rodando no seu Mac.
2. No terminal do Mac, execute o script:
   ```bash
   ./build-docker.sh
   ```
3. O script iniciará um container Arch Linux com privilégios para criar e formatar os arquivos de loopback e compilar a imagem. A ISO final será salva na pasta `out/`.

---

## 💻 Como Instalar Localmente (Usando o Script de Ricing)

Se você preferir instalar o Arch Linux manualmente (por exemplo, em uma Máquina Virtual) e aplicar o visual do SakuraOS nele:

1. Faça uma instalação limpa do Arch Linux com o Desktop Environment **GNOME** ativo.
2. Abra o terminal e instale o Git:
   ```bash
   sudo pacman -S git --noconfirm
   ```
3. Clone este repositório:
   ```bash
   git clone https://github.com/SEU_USUARIO/SAKURA_OS.git
   cd SAKURA_OS
   ```
4. Torne o script executável e execute-o:
   ```bash
   chmod +x setup-sakura.sh
   ./setup-sakura.sh
   ```
5. Reinicie sua sessão ou dê logout para ver as alterações aplicadas!

---

## 🛠️ Como Testar no macOS (Máquina Virtual)

Para rodar a ISO gerada no macOS:

### Se o seu Mac for Apple Silicon (M1, M2, M3):
1. Baixe e instale o [UTM](https://mac.getutm.app/) (ferramenta gratuita de virtualização para macOS).
2. Como a ISO compilada pelo GitHub é de arquitetura `x86_64`, você pode criar uma máquina virtual no UTM selecionando a opção **Emular** (Emulate).
3. Selecione a ISO baixada como imagem de boot.
4. *Dica:* Para maior desempenho em Macs M1/M2/M3, você também pode instalar o Arch Linux ARM64 nativamente na VM UTM (usando Virtualização Nativa) e rodar o script `setup-sakura.sh` diretamente nela.

### Se o seu Mac for Intel:
1. Baixe o [VirtualBox](https://www.virtualbox.org/) ou [VMware Fusion](https://www.vmware.com/products/fusion.html).
2. Crie uma nova máquina virtual selecionando a imagem ISO do SakuraOS para inicializar.
