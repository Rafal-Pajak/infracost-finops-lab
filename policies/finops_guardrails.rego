package infracost

import rego.v1

get_cost(res) := to_number(res.monthlyCost) if {
  res.monthlyCost
} else := to_number(res.monthly_cost) if {
  res.monthly_cost
}

# Reguła 1: Blokuj pojedynczy zasób (posiadający resourceType), jeśli kosztuje > $80/mies.
deny contains msg if {
  walk(input, [_, res])
  is_object(res)
  res.resourceType
  res.name
  cost := get_cost(res)
  cost > 80
  msg := sprintf(
    "FINOPS GUARDRAIL: Zasób '%s' (%s) kosztuje $%v/mies., co przekracza limit $80/mies.",
    [res.name, res.resourceType, cost]
  )
}

# Reguła 2: Blokuj cały projekt, jeśli jego suma przekracza $150/mies.
deny contains msg if {
  some project in input.projects
  cost := get_cost(project)
  cost > 150
  msg := sprintf(
    "FINOPS PROJECT BUDGET: Projekt '%s' kosztuje $%v/mies. (limit: $150/mies.).",
    [project.name, cost]
  )
}

# Reguła pomocnicza dla CI/CD: zwraca true tylko wtedy, gdy brak naruszeń w deny
allow if {
  count(deny) == 0
}
