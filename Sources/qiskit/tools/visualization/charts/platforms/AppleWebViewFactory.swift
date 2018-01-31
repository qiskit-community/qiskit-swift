// Copyright 2018 IBM RESEARCH. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================

#if os(OSX) || os(iOS)

import WebKit

// MARK: - Main body

struct AppleWebViewFactory {

    // MARK: - Public class methods

    static func makeWebView(size: VisualizationTypes.Size, html: String) -> VisualizationTypes.View {
        let width = CGFloat(size.width)
        let height = CGFloat(size.height)

        #if os(OSX)

        let frame = NSMakeRect(0, 0, width, height)

        #else

        let frame = CGRect(x: 0, y: 0, width: width, height: height)

        #endif

        let webview = WKWebView(frame: frame)

        webview.loadHTMLString(html, baseURL: nil)

        return webview
    }
}

#endif
