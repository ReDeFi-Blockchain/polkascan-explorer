#!/bin/sh
#
# Polkascan Explorer
#
# Copyright 2018-2022 Stichting Polkascan (Polkascan Foundation).
# This file is part of Polkascan.
#
# Polkascan is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Polkascan is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Polkascan. If not, see <http://www.gnu.org/licenses/>.
#
set -e

echo "Init Git submodules ..."
git submodule update --init --recursive

echo "Applying patch to explorer-ui..."
cd explorer-ui
git apply ../patches/explorer-ui.patch
cd ..

echo "Copying start scripts to harvester..."
cp start_parachain.sh harvester/
cp start_relay.sh harvester/

echo "Copying explorer-ui-config.json and explorer-ui-privacy-policy.html to explorer-ui..."
cp explorer-ui-config.json explorer-ui/src/assets/config.json
cp explorer-ui-privacy-policy.html explorer-ui/src/assets/privacy-policy.html

echo "Initialization complete!"
