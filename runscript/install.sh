#!/bin/bash
# Настройка автозапуска скриптов
# Запускать через `sudo`

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Файл конфигурации (шаблон, временный файл, результат)
template_file=$current_dir/runscript.service
temp_file=$current_dir/_temp.service
target_filename=runscript.service
target_file=/lib/systemd/system/$target_filename

# Опрос
read -p 'Description [Runscript Service]: ' description
description=${description:-Runscript Service}

default_runscript_file=$HOME/runscript.sh

read -p "Path to runscript file [$default_runscript_file]: " runscript_file
runscript_file=${runscript_file:-$default_runscript_file}

# Если файла нет, создаём
[ ! -f $runscript_file ] && printf "#!/bin/bash\n# $description" > $runscript_file

# Создаём временный файл, подставляем значения
cp $template_file $temp_file

sed -i "s~{description}~$description~g" $temp_file
sed -i "s~{runscript}~$runscript_file~g" $temp_file

# Копируем результат в целевой файл, временный удаляем
cp $temp_file $target_file
rm $temp_file

# Посмотрим, что получилось
cat $target_file

# Права
chmod 644 $target_file
chmod u=rwx,g=rwx,o+rwx $runscript_file

# Обновим конфигурацию и добавим скрипт в автозагрузку Linux
systemctl daemon-reload
systemctl enable $target_filename
