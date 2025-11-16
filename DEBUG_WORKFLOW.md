# 🐛 Diagnostic du Workflow Échoué

## 📍 Comment Trouver l'Erreur

### Étape 1 : Aller sur Actions

```
https://github.com/DrHelios/gamevault-app-private/actions
```

### Étape 2 : Identifier le Workflow Échoué

Vous verrez une liste avec :
- ✅ Workflows réussis (vert)
- ❌ Workflows échoués (rouge)
- 🟡 Workflows en cours (orange)

**Cliquez sur le workflow rouge (❌)**

### Étape 3 : Voir les Détails

Vous verrez :
```
❌ Build GameVault (Paywall Removed)
   master • 5ef06ef

   Jobs:
   ❌ build (ENV_GAMEVAULT)
```

**Cliquez sur "build (ENV_GAMEVAULT)"**

### Étape 4 : Trouver l'Étape qui a Échoué

Une des étapes sera ❌ rouge. Les étapes courantes :

```
✅ Checkout code
✅ Setup .NET
❌ Apply Paywall Removal  ← ERREUR ICI PAR EXEMPLE
⏭️ Restore dependencies (skipped)
⏭️ Build (skipped)
```

**Cliquez sur l'étape rouge pour voir l'erreur exacte**

---

## 🔍 Erreurs Courantes et Solutions

### Erreur 1 : "Environment protection rules not satisfied"

**Message complet :**
```
The environment 'ENV_GAMEVAULT' requires approval before it can be used
```

**Cause :** L'environnement nécessite une validation manuelle

**Solution :**

1. Allez sur : https://github.com/DrHelios/gamevault-app-private/settings/environments

2. Cliquez sur **ENV_GAMEVAULT**

3. Sous "Environment protection rules", décochez :
   - ❌ **Required reviewers**
   - ❌ **Wait timer**

4. Cliquez **Save protection rules**

5. Relancez le workflow : Actions → Workflow échoué → "Re-run failed jobs"

---

### Erreur 2 : "Secret GH_PAT not found"

**Message complet :**
```
Error: Secret GH_PAT doesn't exist
```

**Cause :** Le secret n'est pas dans l'environnement ENV_GAMEVAULT

**Solution :**

1. Allez sur : https://github.com/DrHelios/gamevault-app-private/settings/environments

2. Cliquez sur **ENV_GAMEVAULT**

3. Sous "Environment secrets", vérifiez que **GH_PAT** existe

4. Si absent :
   - Cliquez **Add secret**
   - Name: `GH_PAT`
   - Value: (votre token)

5. Relancez le workflow

---

### Erreur 3 : "Permission denied" lors du Push

**Message complet :**
```
remote: Permission to DrHelios/gamevault-app-private.git denied
fatal: unable to access 'https://github.com/DrHelios/...': The requested URL returned error: 403
```

**Cause :** Le token GH_PAT n'a pas les bonnes permissions

**Solution :**

1. Vérifiez les permissions du token : https://github.com/settings/tokens

2. Le token doit avoir :
   - ✅ **repo** (Full control of private repositories)
   - ✅ **workflow** (Update GitHub Action workflows)

3. Si manquant, créez un nouveau token avec ces permissions

4. Remplacez le secret GH_PAT avec le nouveau token

---

### Erreur 4 : Build Failed (Compilation Error)

**Message complet :**
```
error MSB4019: Microsoft.NET.Sdk.WindowsDesktop.targets introuvable
```
OU
```
Error: Build failed with 1 error(s)
```

**Cause :** Problème de compilation du code C#

**Solutions possibles :**

**A) Si l'erreur mentionne "WindowsDesktop.targets" :**
- Normal sur Linux
- Le workflow utilise `runs-on: windows-latest` donc ça devrait fonctionner
- Vérifiez que le workflow build est bien configuré pour Windows

**B) Si l'erreur mentionne PhalcodeProduct.cs :**
- Le paywall removal n'a peut-être pas été appliqué correctement
- Vérifiez le contenu du fichier sur GitHub
- Re-run le script : `./apply-paywall-removal.sh`

**C) Si autre erreur de compilation :**
- Upstream a peut-être cassé quelque chose
- Vérifiez les changements récents upstream
- Attendez qu'ils fixent, ou fork à un commit stable

---

### Erreur 5 : "gh: command not found"

**Message complet :**
```
/bin/bash: line 1: gh: command not found
Error: Process completed with exit code 127
```

**Cause :** GitHub CLI (gh) non disponible sur le runner

**Solution :**

Le problème est dans l'étape "Create GitHub Release" du workflow build.

**Option 1 : Installer gh dans le workflow**

Éditez `.github/workflows/build-windows.yml`, ajoutez AVANT l'étape "Create GitHub Release" :

```yaml
    - name: Install GitHub CLI
      run: |
        winget install --id GitHub.cli -e --silent
      shell: pwsh
```

**Option 2 : Utiliser l'API REST au lieu de gh**

Remplacez l'étape "Create GitHub Release" par :

```yaml
    - name: Create GitHub Release
      if: github.event_name == 'push'
      run: |
        $version = "v$(Get-Date -Format 'yyyy.MM.dd-HHmmss')"
        $zipFile = Get-ChildItem -Filter "GameVault-NoPaywall-*.zip" | Select-Object -First 1

        # Release notes
        $releaseBody = @"
        # GameVault Private Build - $version

        🔓 All premium features unlocked

        Build: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')
        Commit: $env:GITHUB_SHA
        "@

        # Créer le tag
        git config user.name "GitHub Actions"
        git config user.email "actions@github.com"
        git tag -a "$version" -m "Release $version"
        git push origin "$version"

        # Créer la release via API
        $headers = @{
          "Authorization" = "token $env:GH_TOKEN"
          "Accept" = "application/vnd.github+json"
        }

        $releaseData = @{
          tag_name = $version
          name = "GameVault Private Build $version"
          body = $releaseBody
          draft = $false
          prerelease = $false
        } | ConvertTo-Json

        $release = Invoke-RestMethod -Method POST `
          -Uri "https://api.github.com/repos/$env:GITHUB_REPOSITORY/releases" `
          -Headers $headers `
          -Body $releaseData

        # Upload asset
        $uploadUrl = $release.upload_url -replace '\{\?name,label\}', "?name=$($zipFile.Name)"
        $fileBytes = [System.IO.File]::ReadAllBytes($zipFile.FullName)

        $uploadHeaders = @{
          "Authorization" = "token $env:GH_TOKEN"
          "Content-Type" = "application/zip"
        }

        Invoke-RestMethod -Method POST `
          -Uri $uploadUrl `
          -Headers $uploadHeaders `
          -Body $fileBytes

        Write-Host "✅ Release created: $version"
      shell: pwsh
      env:
        GH_TOKEN: ${{ secrets.GH_PAT }}
        GITHUB_REPOSITORY: ${{ github.repository }}
```

---

### Erreur 6 : "Resource not accessible by integration"

**Message complet :**
```
Error: Resource not accessible by integration
HttpError: Resource not accessible by integration
```

**Cause :** Le `GITHUB_TOKEN` par défaut n'a pas assez de permissions

**Solution :**

Dans le workflow qui échoue (build ou sync), assurez-vous d'utiliser `secrets.GH_PAT` et pas `secrets.GITHUB_TOKEN`.

Vérifiez cette ligne :
```yaml
token: ${{ secrets.GH_PAT }}  # ✅ Correct
# PAS
token: ${{ secrets.GITHUB_TOKEN }}  # ❌ Permissions limitées
```

---

## 🔄 Comment Relancer un Workflow Échoué

1. **Sur la page du workflow échoué**, cliquez **"Re-run failed jobs"** (en haut à droite)

2. OU cliquez **"Re-run all jobs"** pour tout relancer

3. OU faites un nouveau commit :
   ```bash
   cd /home/helios/Projects/gamevault-app
   git commit --allow-empty -m "Trigger rebuild"
   git push origin master
   ```

---

## 📋 Checklist de Diagnostic

Vérifiez dans cet ordre :

- [ ] L'environnement ENV_GAMEVAULT existe
- [ ] Le secret GH_PAT est dans ENV_GAMEVAULT
- [ ] L'environnement n'a PAS de "Required reviewers" activé
- [ ] Le token a les scopes `repo` et `workflow`
- [ ] Le workflow utilise `environment: ENV_GAMEVAULT`
- [ ] Le workflow utilise `secrets.GH_PAT` (pas GITHUB_TOKEN)

---

## 📸 Comment Me Partager l'Erreur

Si vous avez besoin d'aide, donnez-moi :

1. **Le nom du workflow** : "Build GameVault" ou "Sync with Upstream"

2. **L'étape qui échoue** : Ex: "Apply Paywall Removal"

3. **Les premières lignes de l'erreur** : Copiez/collez les 10-20 premières lignes

4. **La configuration** :
   - L'environnement ENV_GAMEVAULT existe-t-il ?
   - Le secret GH_PAT est-il dedans ?
   - Y a-t-il des "protection rules" ?

---

## 🎯 Prochaines Étapes

1. **Allez sur** : https://github.com/DrHelios/gamevault-app-private/actions

2. **Trouvez le workflow rouge**

3. **Identifiez l'erreur** avec ce guide

4. **Appliquez la solution** correspondante

5. **Relancez** le workflow

---

**Si vous ne trouvez pas la solution dans ce guide, donnez-moi le message d'erreur exact et je vous aiderai ! 🚀**
