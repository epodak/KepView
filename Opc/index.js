

import 'babel-polyfill';
import 'core-js/fn/object/assign';
import React from 'react';
import { render } from 'react-dom';
import { browserHistory, Router, Route, IndexRoute} from 'react-router';


import Title from './components/Title';
import Error404 from './components/Error404';
import Explorer from './components/Explorer';
import Index from './components/Index';
import Xsl from './components/Xsl';


        // Render the main component into the dom
        render((
            <Router history={browserHistory}>
                <Route path="/" component={Title}>
                    <IndexRoute component={Index}/>
                    <Route path="explore/*" component={Explorer}/>
                    <Route path="xsl/:xml/:xsl" component={Xsl}/>
                    <Route path="*" component={Error404}/>
                </Route>      
            </Router>
        ), document.getElementById('app'));

                    