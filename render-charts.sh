#!/bin/bash

set -euo pipefail

APP_FILE="argocd-applications/keycloak.yaml"

# Ensure yq is available
if ! command -v yq &> /dev/null; then
  echo "❌ 'yq' is required but not installed. Install it from https://github.com/mikefarah/yq"
  exit 1
fi

# Extract values from the ArgoCD app file
CHART_NAME=$(yq '.spec.sources[0].chart' "$APP_FILE")
CHART_VERSION=$(yq '.spec.sources[0].targetRevision' "$APP_FILE")
OCI_REPO="oci://registry-1.docker.io/bitnamicharts"
VALUES_FILE=$(yq '.spec.sources[0].helm.valueFiles[0]' "$APP_FILE" | sed 's/\$values\///')
NAMESPACE=$(yq '.spec.destination.namespace' "$APP_FILE")
CHART_FILE="${CHART_NAME}-${CHART_VERSION}.tgz"

# Check that values file exists
if [ ! -f "$VALUES_FILE" ]; then
  echo "❌ Values file not found: $VALUES_FILE"
  exit 1
fi

# Pull the chart if needed
if [ ! -f "$CHART_FILE" ]; then
  echo "📦 Pulling chart ${CHART_NAME} version ${CHART_VERSION}..."
  helm pull "${OCI_REPO}/${CHART_NAME}" --version "${CHART_VERSION}"
else
  echo "✅ Chart already exists locally: ${CHART_FILE}"
fi

# Render the chart
if [ ! -d "keycloak/rendered-charts" ]; then
  mkdir -p keycloak/rendered-charts
fi
echo "🛠️ Rendering ${CHART_NAME} with ${VALUES_FILE}..."
helm template "${CHART_NAME}" "${CHART_FILE}" \
  --namespace "${NAMESPACE}" \
  -f "${VALUES_FILE}" > "keycloak/rendered-charts/rendered-${CHART_NAME}.yaml"

echo "✅ Rendered to: rendered-${CHART_NAME}.yaml"

rm -f "${CHART_FILE}"
echo "🗑️ Cleaned up: ${CHART_FILE}"