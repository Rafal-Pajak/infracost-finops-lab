package infracost

import rego.v1

get_cost(res) := to_number(res.monthlyCost) if {
  res.monthlyCost
} else := to_number(res.monthly_cost) if {
  res.monthly_cost
}

# Reguła 1A: Limit $80/mies. na pojedynczy zasób (format Infracost CLI v2 - lokalny)
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

# Reguła 1B: Limit $80/mies. na pojedynczy zasób (format Infracost CLI v0.10.x - GitHub Actions)
deny contains msg if {
  some project in input.projects
  some res in project.breakdown.resources
  cost := get_cost(res)
  cost > 80
  msg := sprintf(
    "FINOPS GUARDRAIL (CI): Zasób '%s' w projekcie '%s' kosztuje $%v/mies., co przekracza limit $80/mies.",
    [res.name, project.name, cost]
  )
}

# Reguła 2: Limit $150/mies. na cały projekt
deny contains msg if {
  some project in input.projects
  cost := get_cost(project)
  cost > 150
  msg := sprintf(
    "FINOPS PROJECT BUDGET: Projekt '%s' kosztuje $%v/mies. (limit: $150/mies.).",
    [project.name, cost]
  )
}

# Reguła 3: Brama logiczna dla CI/CD (zwraca true tylko przy 0 naruszeń)
allow if {
  count(deny) == 0
}
