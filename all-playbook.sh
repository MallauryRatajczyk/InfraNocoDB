for repository in $(ls . | tr '\n' ' ')
do
    if [ -d "${repository}" ]
    then
        cd "${repository}"
        if [ -d "./Ansible" ]
        then
            cd "Ansible"
            ansible-playbook -i inventory.ini main-playbook.yml
            cd ..
        fi
        cd ..
    fi
done