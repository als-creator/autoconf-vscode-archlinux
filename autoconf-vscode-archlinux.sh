#!/bin/bash
set -e

# Блокировка запуска от root
[ "$EUID" -eq 0 ] && { echo "Не запускайте скрипт от root." >&2; exit 1; }

# Проверка наличия sudo
if sudo -l &>/dev/null; then
  echo "Наличие прав sudo проверено"
else
  echo "У вас нет прав sudo"
  exit 1
fi

# Установка yay из AUR вручную, если не найден
command -v yay &>/dev/null \
  || {
    echo "🔄 yay не найден — собираю из AUR..."
    cd /tmp
    [ -d yay ] && rm -rf yay
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
  }

# Имя текущего пользователя
USERNAME="$(whoami)"

# Пути к файлам и папкам
CONFIG_DIR="/home/$USERNAME/.config/Code/User"
EXTENSIONS_DIR="/home/$USERNAME/.vscode/extensions"

# Данные репозитория на GitHub
REPO_OWNER="als-creator"
REPO_NAME="autoconf-vscode-archlinux"
BRANCH="main"

# URL ресурсов
SETTINGS_JSON_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/settings.json"
EXTENSIONS_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/extensions.txt"

# Установка Visual Studio Code через YAY
echo "Начинаю установку Visual Studio Code..."
yay -Sy visual-studio-code-bin --noconfirm
echo "Visual Studio Code установлен"
# Создание директории Config, если её нет
mkdir -p "$CONFIG_DIR"

# Скачивание настроек и помещение их в директорию пользователя
wget -qO- "$SETTINGS_JSON_URL" > "$CONFIG_DIR/settings.json"

# Добавляем синхронизацию папки snippets
SNIPPETS_DIR="${CONFIG_DIR}/snippets"
mkdir -p "$SNIPPETS_DIR"

echo "Скачиваем сниппеты для JavaScript..."
wget -qO- "https://raw.githubusercontent.com/als-creator/autoconf-code-oss-archlinux/main/snippets/javascript.json" > "${SNIPPETS_DIR}/javascript.json"

echo "Скачиваем сниппеты для Python..."
wget -qO- "https://raw.githubusercontent.com/als-creator/autoconf-code-oss-archlinux/main/snippets/python.json" > "${SNIPPETS_DIR}/python.json"

echo "Скачиваем сниппеты для Go..."
wget -qO- "https://raw.githubusercontent.com/als-creator/autoconf-code-oss-archlinux/main/snippets/go.json" > "${SNIPPETS_DIR}/go.json"

echo "Скачиваем сниппеты для PHP..."
wget -qO- "https://raw.githubusercontent.com/als-creator/autoconf-code-oss-archlinux/main/snippets/php.json" > "${SNIPPETS_DIR}/php.json"

echo "Скачиваем сниппеты для Bash/Shell..."
wget -qO- "https://raw.githubusercontent.com/als-creator/autoconf-code-oss-archlinux/main/snippets/shellscript.json" > "${SNIPPETS_DIR}/shellscript.json"

# Установка расширений из списка
EXTENSIONS=$(curl -s "$EXTENSIONS_URL")
for ext in ${EXTENSIONS}; do
  code --install-extension "$ext"
done

# Готово!
echo "Все настройки и сниппеты установлены!"
echo "Путь к сниппетам: $SNIPPETS_DIR"
exit 0
