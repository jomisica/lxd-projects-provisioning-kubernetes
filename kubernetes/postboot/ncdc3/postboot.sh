set -o xtrace
env

# This script will run after basic kubernetes boots. With it we can
# install and configure one or many applications for a given project.
# Using the kubeconfig generated during kubernetes cluster initialization.

#Using kubeconfig from this project
export KUBECONFIG="kubernetes/kubectl-configs/${PROJECT_NAME}/kubeconfig"

# We need to have kubectl installed on the machine where this script is
# running to be able to communicate with the kubernetes cluster of the
# project in question.

# Wait for all nodes to be ready
local t=0
while [ $t -le 300 ]; do
  node_status=$(kubectl get nodes | grep NotReady)
  if [ $? -eq 1 ]; then
    echo "All nodes up..."
    break
  fi
  echo ${node_status}
  sleep 1
  sleep 1
  t=$((t + 1))
done

# At this moment, the nodes already have the Ready status.
# We can install our applications, configure the applications,
# using kubectl to apply templates, use helm, etc.

# get service node port
nodeport=$(kubectl get service/nginx-service -o yaml | grep 'nodePort: ' | sed -e "s?nodePort: ??")
trimedport=$(echo "${nodeport}" | tr -d '\n\r[:space:]')

# We have found a way to test the status of the service.
# In this case sleep 30 seconds or more
sleep 30

# call service
response_test=$(curl http://${K8S_MASTER_INSTANCE_IP}:${trimedport} | grep '<h1>Welcome to nginx!</h1>')

# We test whether the answer, for example, has text, in this example.
# However, we must use more effective methods for testing,
# response status and others.

if [ $? -eq 0 ]; then
  echo "[OK] The answer was as expected"
else
  echo "[error] The response was not what was intended, the test failed."
  exit 255
fi

# We must have and find ways to test our applications in the best way possible.
# This way we know right from the start what didn’t work. Always improve these
# tests until they completely cover the failure points.

exit
