
# K3s amb Ansible — "robust changed" + token sense guardar al repo

## Hosts
- Master: cluster-master (192.168.1.14)
- Worker: custer-node1 (192.168.1.13)

## Ús
ansible-playbook playbooks/site.yml --syntax-check
ansible-playbook playbooks/site.yml --check
ansible-playbook playbooks/site.yml

## Notes
- El token del master es llig amb `slurp` i es passa als workers via `hostvars` (no es guarda en fitxers).
- Les tasques d'instal·lació **no** marquen `changed`; el canvi es marca només si **canvia la versió** abans/després.
- En `--check` s'executen tasques de simulació; les d'instal·lació es desactiven.
