/*
 * Copyright (c) 2013, Swedish Institute of Computer Science
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of The Swedish Institute of Computer Science nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE SWEDISH INSTITUTE OF COMPUTER SCIENCE BE LIABLE 
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

/* Description:
 * TODO:
 * */
package com.sics.sicsthsense.model;

import javax.ws.rs.core.Cookie;
import javax.ws.rs.core.HttpHeaders;
import java.util.UUID;

import com.google.common.base.Optional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.sics.sicsthsense.EngineConfiguration;
import com.sics.sicsthsense.core.InMemoryUserCache;
import com.sics.sicsthsense.core.User;

/**
 * <p>Builder to provide the following to resources:</p>
 * <ul>
 * <li>Utility methods to build backing models for Views</li>
 * </ul>
 *
 * @since 0.0.1
 */
public class ModelBuilder {

  private static final Logger log = LoggerFactory.getLogger(ModelBuilder.class);

  public Optional<UUID> extractSessionToken(HttpHeaders httpHeaders) {

    // Want to fail fast to absent() since this will get called a lot
    Optional<UUID> sessionToken = Optional.absent();

    if (httpHeaders == null) {
      // Might be an internal call such as an error condition
      return sessionToken;
    }
    if (httpHeaders.getCookies() == null) {
      // This is a cold user
      return sessionToken;
    }

    Cookie cookie = httpHeaders.getCookies().get(EngineConfiguration.SESSION_TOKEN_NAME);
    if (cookie == null) {
      // This is a cold user
      return sessionToken;
    }
    String value = cookie.getValue();
    if (value == null) {
      // This is a broken cookie
      // Rather than throw an error we can force a fresh login to fix it up
      return sessionToken;
    }

    // Must be OK to be here
    return Optional.of(UUID.fromString(value));

  }

  /**
   * @return A new base model with user populated from the session token if present
   */
  public BaseModel newBaseModel(HttpHeaders httpHeaders) {

    BaseModel baseModel = new BaseModel();

    // Locate and populate the user by their session token (if present)
    addUser(httpHeaders, baseModel);

    return baseModel;

  }

  /**
   *
   * @param httpHeaders The HTTP headers containing the session token
   * @param baseModel A base model
   */
  public void addUser(HttpHeaders httpHeaders, BaseModel baseModel) {
    Optional<UUID> sessionToken = extractSessionToken(httpHeaders);
    if (sessionToken.isPresent()) {
      Optional<User> user = InMemoryUserCache.INSTANCE.getBySessionToken(sessionToken.get());
      if (user.isPresent()) {
        log.debug("Found a user to match the session token {}",sessionToken.get());
        baseModel.setUser(user.get());
      } else {
        log.debug("No user matching the session token {}",sessionToken.get());
      }
    }
  }

}
