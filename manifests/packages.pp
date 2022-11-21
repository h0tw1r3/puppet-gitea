# @summary install required system packages
#
# @api private
#
# @param dependencies_ensure
#   Should dependencies be installed?
#
# @param dependencies
#   List of required packages
#
class gitea::packages (
  Enum['latest','present','absent'] $dependencies_ensure = $gitea::dependencies_ensure,
  Array[String] $dependencies = $gitea::dependencies,
) {
  if ($dependencies_ensure) {
    ensure_packages($dependencies, { 'ensure' => $dependencies_ensure })
  }
}
