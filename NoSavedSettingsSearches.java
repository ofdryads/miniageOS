/*
 * Copyright (C) 2017 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
    Modified version of the original file that will prevent things you search in settings from being saved and suggested to you
    Path to original file: $lineage_root/packages/apps/SettingsIntelligence/src/com/android/settings/intelligence/search/savedqueries/SavedQueryRecorder.java
*/

package com.android.settings.intelligence.search.savedqueries;

import android.content.Context;

import com.android.settings.intelligence.utils.AsyncLoader;

public class SavedQueryRecorder extends AsyncLoader<Void> {

    private static final String LOG_TAG = "SavedQueryRecorder";

    // Max number of saved search queries (who will be used for proposing suggestions)
    private static long MAX_SAVED_SEARCH_QUERY = 0;

    public SavedQueryRecorder(Context context) {
        super(context);
    }

    @Override
    protected void onDiscardResult(Void result) {

    }

    @Override
    public Void loadInBackground() {
        return null;
    }
}
